--# inherit
--#    X86_64,
--#    SK.CPU,
--#    SK.Interrupts,
--#    SK.GDT,
--#    SK.Descriptors,
--#    SK.Constants,
--#    SK.Subject;
package SK.VMX
--# own
--#    VMXON_Address,
--#    VMCS_Address,
--#    VMX_Exit_Address,
--#    Kernel_Stack_Address,
--#    Guest_Stack_Address;
--# initializes
--#    VMXON_Address,
--#    VMCS_Address,
--#    VMX_Exit_Address,
--#    Kernel_Stack_Address,
--#    Guest_Stack_Address;
is

   procedure Enable;
   --# global
   --#    in     VMXON_Address;
   --#    in out X86_64.State;
   --# derives
   --#    X86_64.State from *, VMXON_Address;

   procedure Launch;
   --# global
   --#    in     GDT.GDT_Pointer;
   --#    in     Interrupts.IDT_Pointer;
   --#    in     VMCS_Address;
   --#    in     VMX_Exit_Address;
   --#    in     Kernel_Stack_Address;
   --#    in     Guest_Stack_Address;
   --#    in out X86_64.State;
   --# derives
   --#    X86_64.State from
   --#       *,
   --#       Interrupts.IDT_Pointer,
   --#       GDT.GDT_Pointer,
   --#       VMCS_Address,
   --#       VMX_Exit_Address,
   --#       Kernel_Stack_Address,
   --#       Guest_Stack_Address;

private

   --  VMX exit handler.
   procedure Handle_Vmx_Exit;
   --# global
   --#    in out X86_64.State;
   --# derives
   --#    X86_64.State from *;
   pragma Export (C, Handle_Vmx_Exit, "handle_vmx_exit");

end SK.VMX;
