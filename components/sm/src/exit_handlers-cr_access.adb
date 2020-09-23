--
--  Copyright (C) 2013-2016  Reto Buerki <reet@codelabs.ch>
--  Copyright (C) 2013-2016  Adrian-Ken Rueegsegger <ken@codelabs.ch>
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--

with Ada.Unchecked_Conversion;

with SK.Strings;

with Debug_Ops;

pragma $Release_Warnings
  (Off, "unit ""Sm_Component.Config"" is not referenced",
   Reason => "Only used to control debug output");
with Sm_Component.Config;
pragma $Release_Warnings
  (On, "unit ""Sm_Component.Config"" is not referenced");

package body Exit_Handlers.CR_Access
is

   use Subject_Info;
   use type SK.Word64;

   --  Types related to control register specific exit qualification.

   type CR_Number_Type is mod 2 ** 4
     with Size => 4;

   type CR_Access_Type is (MOV_To_CR, MOV_From_CR, CLTS, LMSW)
     with Size => 2;
   for CR_Access_Type use
     (MOV_To_CR   => 0,
      MOV_From_CR => 1,
      CLTS        => 2,
      LMSW        => 3);

   type LMSW_Operand_Type is (Register, Memory)
     with Size => 1;
   for LMSW_Operand_Type use
     (Register => 0,
      Memory   => 1);

   type CR_Info_Type is record
      CR_Number     : CR_Number_Type;
      CR_Access     : CR_Access_Type;
      LMSW_Operand  : LMSW_Operand_Type;
      Reserved_1    : SK.Bit_Type;
      Data_Register : Types.Data_Register_Type;
      Reserved_2    : SK.Bit_Array (1 .. 4);
      Source_Data   : SK.Word16;
      Reserved_3    : SK.Word32;
   end record
     with Object_Size => 64;

   for CR_Info_Type use record
      CR_Number     at 0 range  0 ..  3;
      CR_Access     at 0 range  4 ..  5;
      LMSW_Operand  at 0 range  6 ..  6;
      Reserved_1    at 0 range  7 ..  7;
      Data_Register at 0 range  8 .. 11;
      Reserved_2    at 0 range 12 .. 15;
      Source_Data   at 0 range 16 .. 31;
      Reserved_3    at 0 range 32 .. 63;
   end record;

   -------------------------------------------------------------------------

   --  Return CR access information from exit qualification, as specified by
   --  Intel SDM Vol. 3C, "27.2.1 Basic VM-Exit Information", table 27-3.
   function To_CR_Info (Qualification : SK.Word64) return CR_Info_Type
   is
      function To_CR_Information is new Ada.Unchecked_Conversion
        (Source => SK.Word64,
         Target => CR_Info_Type);
   begin
      return To_CR_Information (Qualification);
   end To_CR_Info;

   -------------------------------------------------------------------------

   procedure Process (Action : out Types.Subject_Action_Type)
   is
      use type Types.Data_Register_Type;

      CR0        : SK.Word64;
      Exit_Q     : constant SK.Word64 := State.Exit_Qualification;
      SHADOW_CR0 : constant SK.Word64 := State.Regs.RAX;

      Info : constant CR_Info_Type := To_CR_Info (Qualification => Exit_Q);
   begin
      Action := Types.Subject_Continue;

      if Info.CR_Access = MOV_To_CR then
         if Info.CR_Number = 0 then
            if Info.Data_Register = Types.RAX then
               State.SHADOW_CR0 := SHADOW_CR0;
               CR0              := SHADOW_CR0 or 16#20#; -- CR0_FIXED0
               State.CR0        := CR0;
               pragma Debug (Sm_Component.Config.Debug_Cr,
                             Debug_Ops.Put_String
                               (Item => "MOV to CR0: SHADOW_CR0 "));
               pragma Debug
                 (Sm_Component.Config.Debug_Cr,
                  Debug_Ops.Put_Line
                    (Item => SK.Strings.Img (SHADOW_CR0) & ", CR0 "
                     & SK.Strings.Img (CR0)));
            else
               pragma Debug
                 (Sm_Component.Config.Debug_Cr,
                  Debug_Ops.Put_Line
                    (Item => "MOV from unsupported register to CR "
                     & SK.Strings.Img (SK.Byte (Info.CR_Number))));
               Action := Types.Subject_Halt;
            end if;
         else
            pragma Debug (Sm_Component.Config.Debug_Cr,
                          Debug_Ops.Put_Line
                            (Item => "Unhandled MOV to CR "
                             & SK.Strings.Img (SK.Byte (Info.CR_Number))));
            Action := Types.Subject_Halt;
         end if;
      else
         pragma Debug (Sm_Component.Config.Debug_Cr,
                       Debug_Ops.Put_Line
                         (Item => "Unhandled CR access method"));
         Action := Types.Subject_Halt;
      end if;
   end Process;

end Exit_Handlers.CR_Access;
