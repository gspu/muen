with System;

with Skp.Interrupts;

with SK.VMX;
with SK.Constants;
with SK.KC;
with SK.CPU;
with SK.CPU_Global;
with SK.Subjects;
with SK.Apic;
with SK.MP;

package body SK.Scheduler
--# own
--#    State is in New_Major, Current_Major;
is

   Tau0_Kernel_Iface_Address : SK.Word64;
   pragma Import (C, Tau0_Kernel_Iface_Address, "tau0kernel_iface_ptr");

   New_Major : Skp.Scheduling.Major_Frame_Range;
   for New_Major'Address use System'To_Address (Tau0_Kernel_Iface_Address);
   --# assert New_Major'Always_Valid;

   --  Current major.
   Current_Major : Skp.Scheduling.Major_Frame_Range
     := Skp.Scheduling.Major_Frame_Range'First;

   -------------------------------------------------------------------------

   --  Return CPU scheduling ID.
   procedure Get_ID (ID : out Skp.CPU_Range)
   --# global
   --#    in out X86_64.State;
   --# derives
   --#    X86_64.State from * &
   --#    ID           from X86_64.State;
   is
      Apic_ID : SK.Byte;
   begin
      ID      := 0;
      Apic_ID := Apic.Get_ID;

      if Apic_ID > SK.Byte (Skp.CPU_Range'Last) then
         pragma Debug (KC.Put_String (Item => "CPU ID not in range: "));
         pragma Debug (KC.Put_Byte   (Item => Apic_ID));
         pragma Debug (KC.New_Line);
         CPU.Panic;
      else
         ID := Skp.CPU_Range (Apic_ID);
      end if;
   end Get_ID;

   -------------------------------------------------------------------------

   --  Read VMCS fields and store them in the given subject state.
   procedure Store_Subject_Info (State : in out SK.Subject_State_Type)
   --# global
   --#    in out X86_64.State;
   --# derives
   --#    X86_64.State from * &
   --#    State        from *, X86_64.State;
   is
   begin
      VMX.VMCS_Read (Field => Constants.VMX_EXIT_QUALIFICATION,
                     Value => State.Exit_Qualification);
      VMX.VMCS_Read (Field => Constants.VMX_EXIT_INTR_INFO,
                     Value => State.Interrupt_Info);
      VMX.VMCS_Read (Field => Constants.VMX_EXIT_INSTRUCTION_LEN,
                     Value => State.Instruction_Len);

      VMX.VMCS_Read (Field => Constants.GUEST_RIP,
                     Value => State.RIP);
      VMX.VMCS_Read (Field => Constants.GUEST_SEL_CS,
                     Value => State.CS);
      VMX.VMCS_Read (Field => Constants.GUEST_RSP,
                     Value => State.RSP);
      VMX.VMCS_Read (Field => Constants.GUEST_SEL_SS,
                     Value => State.SS);
      VMX.VMCS_Read (Field => Constants.GUEST_CR0,
                     Value => State.CR0);
      VMX.VMCS_Read (Field => Constants.GUEST_CR3,
                     Value => State.CR3);
      VMX.VMCS_Read (Field => Constants.GUEST_CR4,
                     Value => State.CR4);
      VMX.VMCS_Read (Field => Constants.GUEST_RFLAGS,
                     Value => State.RFLAGS);
   end Store_Subject_Info;

   -------------------------------------------------------------------------

   --  Update scheduling information. If the end of the current major frame is
   --  reached, the minor frame index is reset and the major frame is switched
   --  to the one set by Tau0. Otherwise the minor frame index is incremented
   --  by 1.
   procedure Update_Scheduling_Info
   --# global
   --#    in     New_Major;
   --#    in out X86_64.State;
   --#    in out Current_Major;
   --#    in out CPU_Global.Storage;
   --#    in out MP.Barrier;
   --# derives
   --#    MP.Barrier from
   --#       *,
   --#       Current_Major,
   --#       CPU_Global.Storage &
   --#    Current_Major, CPU_Global.Storage, X86_64.State from
   --#       Current_Major,
   --#       CPU_Global.Storage,
   --#       New_Major,
   --#       X86_64.State;
   is
      Minor_Frame : CPU_Global.Active_Minor_Frame_Type;
      Plan_Frame  : Skp.Scheduling.Minor_Frame_Type;
   begin
      Minor_Frame := CPU_Global.Get_Current_Minor_Frame;

      if Minor_Frame.Minor_Id < CPU_Global.Get_Major_Length
        (Major_Id => Current_Major)
      then

         --  Switch to next minor frame in current major frame.

         Minor_Frame.Minor_Id := Minor_Frame.Minor_Id + 1;
      else

         --  Switch to first minor frame in next major frame.

         Minor_Frame.Minor_Id := Skp.Scheduling.Minor_Frame_Range'First;

         MP.Wait_For_All;
         if Apic.Is_BSP then
            Current_Major := New_Major;
         end if;
         MP.Wait_For_All;
      end if;

      Plan_Frame := CPU_Global.Get_Minor_Frame
        (Major_Id => Current_Major,
         Minor_Id => Minor_Frame.Minor_Id);
      Minor_Frame.Subject_Id := Plan_Frame.Subject_Id;
      CPU_Global.Set_Current_Minor (Frame => Minor_Frame);

      --  Update preemption timer ticks in subject VMCS.

      VMX.VMCS_Write (Field => Constants.GUEST_VMX_PREEMPT_TIMER,
                      Value => SK.Word64 (Plan_Frame.Ticks));
   end Update_Scheduling_Info;

   -------------------------------------------------------------------------

   procedure Init
   --# global
   --#    in     Current_Major;
   --#    in out X86_64.State;
   --#    in out CPU_Global.Storage;
   --# derives
   --#    X86_64.State       from * &
   --#    CPU_Global.Storage from *, Current_Major, X86_64.State;
   is
      CPU_ID     : Skp.CPU_Range;
      Plan_Frame : Skp.Scheduling.Minor_Frame_Type;
   begin
      Get_ID (ID => CPU_ID);
      CPU_Global.Set_Scheduling_Plan
        (Data => Skp.Scheduling.Scheduling_Plans (CPU_ID));

      --  Set initial active minor frame.

      Plan_Frame := CPU_Global.Get_Minor_Frame
        (Major_Id => Current_Major,
         Minor_Id => Skp.Scheduling.Minor_Frame_Range'First);
      CPU_Global.Set_Current_Minor
        (Frame => CPU_Global.Active_Minor_Frame_Type'
           (Minor_Id   => Skp.Scheduling.Minor_Frame_Range'First,
            Subject_Id => Plan_Frame.Subject_Id));
   end Init;

   -------------------------------------------------------------------------

   procedure Handle_Hypercall
     (Current_Subject :        Skp.Subject_Id_Type;
      Subject_State   : in out SK.Subject_State_Type)
   --# global
   --#    in out CPU_Global.Storage;
   --#    in out Subjects.Descriptors;
   --# derives
   --#    CPU_Global.Storage, Subjects.Descriptors from
   --#       *,
   --#       Current_Subject,
   --#       Subject_State &
   --#    Subject_State from *;
   is
      Signal    : Skp.Subjects.Signal_Range;
      Sig_Entry : Skp.Subjects.Signal_Entry_Type;
      Valid_Sig : Boolean;
   begin
      Valid_Sig := Subject_State.Regs.RAX <= SK.Word64
        (Skp.Subjects.Signal_Range'Last);

      if Valid_Sig then
         Signal    := Skp.Subjects.Signal_Range (Subject_State.Regs.RAX);
         Sig_Entry := Skp.Subjects.Subject_Specs
           (Current_Subject).Signal_Table (Signal);

         if Sig_Entry.Dst_Subject /= Skp.Invalid_Subject then
            if Sig_Entry.Dst_Vector /= Skp.Invalid_Vector then
               Subjects.Set_Pending_Event
                 (Id     => Sig_Entry.Dst_Subject,
                  Vector => SK.Byte (Sig_Entry.Dst_Vector));
            end if;

            if Sig_Entry.Kind = Skp.Subjects.Handover then

               --# accept Warning, 444, "Guaranteed by validated policy";
               --# assume Current_Subject /= Sig_Entry.Dst_Subject;
               --# end accept;

               CPU_Global.Swap_Subject
                 (Old_Id => Current_Subject,
                  New_Id => Sig_Entry.Dst_Subject);
            end if;
         end if;
      end if;

      pragma Debug (not Valid_Sig or Sig_Entry = Skp.Subjects.Null_Signal,
                    KC.Put_String (Item => "Ignoring spurious signal "));
      pragma Debug (not Valid_Sig or Sig_Entry = Skp.Subjects.Null_Signal,
                    KC.Put_Byte   (Item => SK.Byte (Signal)));
      pragma Debug (not Valid_Sig or Sig_Entry = Skp.Subjects.Null_Signal,
                    KC.Put_String (Item => " from subject "));
      pragma Debug (not Valid_Sig or Sig_Entry = Skp.Subjects.Null_Signal,
                    KC.Put_Byte   (Item => SK.Byte (Current_Subject)));
      pragma Debug (not Valid_Sig or Sig_Entry = Skp.Subjects.Null_Signal,
                    KC.New_Line);

      Subject_State.RIP := Subject_State.RIP +
        Subject_State.Instruction_Len;
   end Handle_Hypercall;

   -------------------------------------------------------------------------

   --  Handle external interrupt request with given vector.
   procedure Handle_Irq (Vector : SK.Byte)
   --# global
   --#    in out X86_64.State;
   --#    in out Subjects.Descriptors;
   --# derives
   --#    Subjects.Descriptors from *, Vector &
   --#    X86_64.State         from *;
   is
   begin
      if Vector in Skp.Interrupts.Remapped_Vector_Type then
         if Skp.Interrupts.Vector_Routing (Vector) in Skp.Subject_Id_Type then
            Subjects.Set_Pending_Event
              (Id     => Skp.Interrupts.Vector_Routing (Vector),
               Vector => Vector);
         end if;

         pragma Debug
           (Skp.Interrupts.Vector_Routing (Vector) not in Skp.Subject_Id_Type,
            KC.Put_String (Item => "Spurious IRQ vector "));
         pragma Debug
           (Skp.Interrupts.Vector_Routing (Vector) not in Skp.Subject_Id_Type,
            KC.Put_Byte (Item => Vector));
         pragma Debug
           (Skp.Interrupts.Vector_Routing (Vector) not in Skp.Subject_Id_Type,
            KC.New_Line);
      end if;

      pragma Debug (Vector not in Skp.Interrupts.Remapped_Vector_Type,
                    KC.Put_String (Item => "IRQ with invalid vector "));
      pragma Debug (Vector not in Skp.Interrupts.Remapped_Vector_Type,
                    KC.Put_Byte (Item => Vector));
      pragma Debug (Vector not in Skp.Interrupts.Remapped_Vector_Type,
                    KC.New_Line);

      Apic.EOI;
   end Handle_Irq;

   -------------------------------------------------------------------------

   --  Handle trap using trap table of current subject.
   procedure Handle_Trap
     (Current_Subject : Skp.Subject_Id_Type;
      Subject_State   : SK.Subject_State_Type)
   --# global
   --#    in out X86_64.State;
   --#    in out Subjects.Descriptors;
   --#    in out CPU_Global.Storage;
   --# derives
   --#    X86_64.State, Subjects.Descriptors, CPU_Global.Storage from
   --#       *,
   --#       Current_Subject,
   --#       Subject_State;
   --# pre
   --#    Subject_State.Exit_Reason <= Sk.Word64
   --#       (Skp.Subjects.Trap_Range'Last);
   is
      Trap_Entry : Skp.Subjects.Trap_Entry_Type;
   begin
      Trap_Entry := Skp.Subjects.Subject_Specs (Current_Subject).Trap_Table
        (Skp.Subjects.Trap_Range (Subject_State.Exit_Reason));

      if Trap_Entry.Dst_Subject = Skp.Invalid_Subject then
         pragma Debug (KC.Put_String (Item => "Subject "));
         pragma Debug (KC.Put_Byte   (Item =>  Byte (Current_Subject)));
         pragma Debug (KC.Put_String (Item => " no handler for trap "));
         pragma Debug (KC.Put_Word16 (Item => Word16
                                      (Subject_State.Exit_Reason)));
         pragma Debug (KC.Put_String (Item => ":"));
         pragma Debug (KC.Put_Word32 (Item => Word32
                                      (Subject_State.Exit_Qualification)));
         pragma Debug (KC.New_Line);
         CPU.Panic;
      else
         if Trap_Entry.Dst_Vector < Skp.Invalid_Vector then
            Subjects.Set_Pending_Event
              (Id     => Trap_Entry.Dst_Subject,
               Vector => SK.Byte (Trap_Entry.Dst_Vector));
         end if;

         --  Handover to trap handler subject.

         --# accept Warning, 444, "Guaranteed by validated policy";
         --# assume Current_Subject /= Trap_Entry.Dst_Subject;
         --# end accept;

         CPU_Global.Swap_Subject
           (Old_Id => Current_Subject,
            New_Id => Trap_Entry.Dst_Subject);
      end if;
   end Handle_Trap;

   -------------------------------------------------------------------------

   procedure Schedule
   --# global
   --#    in     VMX.State;
   --#    in     GDT.GDT_Pointer;
   --#    in     Interrupts.IDT_Pointer;
   --#    in     Current_Major;
   --#    in     CPU_Global.Storage;
   --#    in out X86_64.State;
   --#    in out Subjects.Descriptors;
   --# derives
   --#    Subjects.Descriptors from
   --#       *,
   --#       Current_Major,
   --#       CPU_Global.Storage,
   --#       X86_64.State &
   --#    X86_64.State from
   --#       *,
   --#       VMX.State,
   --#       GDT.GDT_Pointer,
   --#       Interrupts.IDT_Pointer,
   --#       Subjects.Descriptors,
   --#       CPU_Global.Storage,
   --#       Current_Major;
   is
      Plan_Frame    : Skp.Scheduling.Minor_Frame_Type;
      Current_Frame : CPU_Global.Active_Minor_Frame_Type;
   begin
      Current_Frame := CPU_Global.Get_Current_Minor_Frame;
      Plan_Frame    := CPU_Global.Get_Minor_Frame
        (Major_Id => Current_Major,
         Minor_Id => Current_Frame.Minor_Id);

      if Subjects.Get_State (Id => Plan_Frame.Subject_Id).Launched then
         VMX.Resume (Subject_Id => Plan_Frame.Subject_Id);
      else
         VMX.Launch (Subject_Id => Plan_Frame.Subject_Id);
      end if;
   end Schedule;

   -------------------------------------------------------------------------

   procedure Handle_Vmx_Exit (Subject_Registers : SK.CPU_Registers_Type)
   --# global
   --#    in     GDT.GDT_Pointer;
   --#    in     Interrupts.IDT_Pointer;
   --#    in     VMX.State;
   --#    in     New_Major;
   --#    in out CPU_Global.Storage;
   --#    in out Current_Major;
   --#    in out MP.Barrier;
   --#    in out Subjects.Descriptors;
   --#    in out X86_64.State;
   --# derives
   --#    CPU_Global.Storage from
   --#       *,
   --#       Current_Major,
   --#       New_Major,
   --#       Subject_Registers,
   --#       Subjects.Descriptors,
   --#       X86_64.State &
   --#    Current_Major from
   --#       *,
   --#       New_Major,
   --#       Subject_Registers,
   --#       Subjects.Descriptors,
   --#       CPU_Global.Storage,
   --#       X86_64.State &
   --#    MP.Barrier from
   --#       *,
   --#       Current_Major,
   --#       Subject_Registers,
   --#       Subjects.Descriptors,
   --#       CPU_Global.Storage,
   --#       X86_64.State &
   --#    X86_64.State from
   --#       *,
   --#       Subject_Registers,
   --#       New_Major,
   --#       Current_Major,
   --#       VMX.State,
   --#       Interrupts.IDT_Pointer,
   --#       GDT.GDT_Pointer,
   --#       CPU_Global.Storage,
   --#       Subjects.Descriptors &
   --#    Subjects.Descriptors from
   --#       *,
   --#       CPU_Global.Storage,
   --#       X86_64.State,
   --#       Subject_Registers,
   --#       New_Major,
   --#       Current_Major;
   is
      State           : SK.Subject_State_Type;
      Current_Subject : Skp.Subject_Id_Type;
      Current_Minor   : CPU_Global.Active_Minor_Frame_Type;
   begin
      Current_Minor := CPU_Global.Get_Current_Minor_Frame;

      Current_Subject := CPU_Global.Get_Minor_Frame
        (Major_Id => Current_Major,
         Minor_Id => Current_Minor.Minor_Id).Subject_Id;
      State      := Subjects.Get_State (Id => Current_Subject);
      State.Regs := Subject_Registers;

      VMX.VMCS_Read (Field => Constants.VMX_EXIT_REASON,
                     Value => State.Exit_Reason);
      Store_Subject_Info (State => State);

      if SK.Bit_Test (Value => State.Exit_Reason,
                      Pos   => Constants.VM_EXIT_ENTRY_FAILURE)
      then
         pragma Debug (KC.Put_String (Item => "Subject "));
         pragma Debug (KC.Put_Byte   (Item =>  Byte (Current_Subject)));
         pragma Debug (KC.Put_String (Item => " VM-entry failure ("));
         pragma Debug (KC.Put_Word16 (Item => Word16 (State.Exit_Reason)));
         pragma Debug (KC.Put_String (Item => ":"));
         pragma Debug (KC.Put_Word32
                       (Item => Word32 (State.Exit_Qualification)));
         pragma Debug (KC.Put_Line   (Item => ")"));
         CPU.Panic;
      end if;

      if State.Exit_Reason = Constants.VM_EXIT_EXTERNAL_INT then
         Handle_Irq (Vector => SK.Byte'Mod (State.Interrupt_Info));
      elsif State.Exit_Reason = Constants.VM_EXIT_HYPERCALL then
         Handle_Hypercall (Current_Subject => Current_Subject,
                           Subject_State   => State);
      elsif State.Exit_Reason = Constants.VM_EXIT_TIMER_EXPIRY then

         --  Minor frame ticks consumed, update scheduling information.

         Update_Scheduling_Info;
      else
         if State.Exit_Reason <= SK.Word64 (Skp.Subjects.Trap_Range'Last) then
            Handle_Trap (Current_Subject => Current_Subject,
                         Subject_State   => State);
         else
            pragma Debug (KC.Put_String (Item => "Subject "));
            pragma Debug (KC.Put_Byte   (Item =>  Byte (Current_Subject)));
            pragma Debug (KC.Put_String (Item => " unhandled trap ("));
            pragma Debug (KC.Put_Word16 (Item => Word16 (State.Exit_Reason)));
            pragma Debug (KC.Put_String (Item => ":"));
            pragma Debug (KC.Put_Word32
                          (Item => Word32 (State.Exit_Qualification)));
            pragma Debug (KC.Put_Line   (Item => ")"));
            CPU.Panic;
         end if;
      end if;

      Subjects.Set_State (Id    => Current_Subject,
                          State => State);

      Schedule;
   end Handle_Vmx_Exit;

end SK.Scheduler;
