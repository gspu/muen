with SK.CPU;
with SK.KC;
with SK.Constants;

package body SK.System_State
is

   -------------------------------------------------------------------------

   --  Check required VMX-fixed bits of given register, see Intel SDM 3C,
   --  appendix A.7 & A.8.
   function Fixed_Valid
     (Register : SK.Word64;
      Fixed0   : SK.Word64;
      Fixed1   : SK.Word64)
      return Boolean
   is
   begin
      return
        ((Fixed0 or  Register) = Register) and
        ((Fixed1 and Register) = Register);
   end Fixed_Valid;

   -------------------------------------------------------------------------

   --  Returns True if local APIC is present and supports x2APIC mode, see
   --  Intel SDM 3A, chapters 10.4.2 and 10.12.1.
   function Has_X2_Apic return Boolean
   --# global
   --#    X86_64.State;
   is
      Unused_EAX, Unused_EBX, ECX, EDX : SK.Word32;
   begin
      Unused_EAX := 1;
      ECX        := 0;

      --# accept Flow, 10, Unused_EAX, "Result unused" &
      --#        Flow, 10, Unused_EBX, "Result unused";
      CPU.CPUID
        (EAX => Unused_EAX,
         EBX => Unused_EBX,
         ECX => ECX,
         EDX => EDX);

      --# accept Flow, 33, Unused_EBX, "Result unused";
      return SK.Bit_Test
        (Value => SK.Word64 (EDX),
         Pos   => Constants.CPUID_FEATURE_LOCAL_APIC) and then
        SK.Bit_Test
          (Value => SK.Word64 (ECX),
           Pos   => Constants.CPUID_FEATURE_X2APIC);
   end Has_X2_Apic;

   -------------------------------------------------------------------------

   --  Returns true if VMX is supported by the CPU.
   function Has_VMX_Support return Boolean
   --# global
   --#    X86_64.State;
   is
      Unused_EAX, Unused_EBX, ECX, Unused_EDX : SK.Word32;
   begin
      Unused_EAX := 1;
      ECX        := 0;

      --# accept Flow, 10, Unused_EAX, "Result unused" &
      --#        Flow, 10, Unused_EBX, "Result unused" &
      --#        Flow, 10, Unused_EDX, "Result unused";
      CPU.CPUID
        (EAX => Unused_EAX,
         EBX => Unused_EBX,
         ECX => ECX,
         EDX => Unused_EDX);

      --# accept Flow, 33, Unused_EBX, "Result unused" &
      --#        Flow, 33, Unused_EDX, "Result unused";
      return SK.Bit_Test
        (Value => SK.Word64 (ECX),
         Pos   => Constants.CPUID_FEATURE_VMX_FLAG);
   end Has_VMX_Support;

   -------------------------------------------------------------------------

   function Is_Valid return Boolean
   is
      VMX_Support, VMX_Locked, Protected_Mode            : Boolean;
      Paging, IA_32e_Mode, Apic_Support                  : Boolean;
      CR0_Valid, CR4_Valid, Not_Virtual_8086, Not_In_SMX : Boolean;
   begin
      VMX_Support := Has_VMX_Support;
      pragma Debug
        (not VMX_Support, KC.Put_Line (Item => "VMX not supported"));

      VMX_Locked := SK.Bit_Test
        (Value => CPU.Get_MSR64 (Register => Constants.IA32_FEATURE_CONTROL),
         Pos   => 0);
      pragma Debug
        (not VMX_Locked,
         KC.Put_Line (Item => "IA32_FEATURE_CONTROL not locked"));

      Protected_Mode := SK.Bit_Test
        (Value => CPU.Get_CR0,
         Pos   => Constants.CR0_PE_FLAG);
      pragma Debug
        (not Protected_Mode,
         KC.Put_Line (Item => "Protected mode not enabled"));

      Paging := SK.Bit_Test
        (Value => CPU.Get_CR0,
         Pos   => Constants.CR0_PG_FLAG);
      pragma Debug
        (not Paging,
         KC.Put_Line (Item => "Paging not enabled"));

      IA_32e_Mode := SK.Bit_Test
        (Value => CPU.Get_MSR64 (Register => Constants.IA32_EFER),
         Pos   => Constants.IA32_EFER_LMA_FLAG);
      pragma Debug
        (not IA_32e_Mode, KC.Put_Line (Item => "IA-32e mode not enabled"));

      Not_Virtual_8086 := not SK.Bit_Test
        (Value => CPU.Get_RFLAGS,
         Pos   => Constants.RFLAGS_VM_FLAG);
      pragma Debug
        (not Not_Virtual_8086,
         KC.Put_Line (Item => "Virtual-8086 mode enabled"));

      Not_In_SMX := SK.Bit_Test
        (Value => CPU.Get_MSR64 (Register => Constants.IA32_FEATURE_CONTROL),
         Pos   => Constants.IA32_FCTRL_SMX_FLAG);
      pragma Debug (not Not_In_SMX, KC.Put_Line (Item => "SMX mode enabled"));

      CR0_Valid := Fixed_Valid
        (Register => CPU.Get_CR0,
         Fixed0   => CPU.Get_MSR64
           (Register => Constants.IA32_VMX_CR0_FIXED0),
         Fixed1   => CPU.Get_MSR64
           (Register => Constants.IA32_VMX_CR0_FIXED1));
      pragma Debug (not CR0_Valid, KC.Put_Line (Item => "CR0 is invalid"));

      CR4_Valid := Fixed_Valid
        (Register => SK.Bit_Set
           (Value => CPU.Get_CR4,
            Pos   => Constants.CR4_VMXE_FLAG),
         Fixed0   => CPU.Get_MSR64
           (Register => Constants.IA32_VMX_CR4_FIXED0),
         Fixed1   => CPU.Get_MSR64
           (Register => Constants.IA32_VMX_CR4_FIXED1));
      pragma Debug
        (not CR4_Valid,
         KC.Put_Line (Item => "CR4 is invalid"));

      Apic_Support := Has_X2_Apic;
      pragma Debug
        (not Apic_Support, KC.Put_Line (Item => "Local x2APIC not present"));

      return VMX_Support and
        VMX_Locked       and
        Protected_Mode   and
        Paging           and
        IA_32e_Mode      and
        Not_Virtual_8086 and
        Not_In_SMX       and
        CR0_Valid        and
        CR4_Valid        and
        Apic_Support;
   end Is_Valid;

end SK.System_State;
