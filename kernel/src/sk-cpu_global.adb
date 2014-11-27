--
--  Copyright (C) 2013  Reto Buerki <reet@codelabs.ch>
--  Copyright (C) 2013  Adrian-Ken Rueegsegger <ken@codelabs.ch>
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

with System;

with Skp.Kernel;

package body SK.CPU_Global
with
   Refined_State => (State => (Per_CPU_Storage, Current_Major_Frame))
is

   use type Skp.Scheduling.Major_Frame_Array;
   use type Skp.Scheduling.Major_Frame_Range;
   use type Skp.Scheduling.Minor_Frame_Range;
   use type Skp.Scheduling.Scheduling_Group_Array;

   --  Record used to store per-CPU global data.
   type Storage_Type is record
      Scheduling_Plan     : Skp.Scheduling.Major_Frame_Array;
      Scheduling_Groups   : Skp.Scheduling.Scheduling_Group_Array;
      Current_Minor_Frame : Active_Minor_Frame_Type;
   end record;

   pragma $Build_Warnings (Off, "* bits of ""Per_CPU_Storage"" unused");
   Per_CPU_Storage : Storage_Type
   with
      Address => System'To_Address (Skp.Kernel.CPU_Store_Address + 8),
      Size    => 8 * (SK.Page_Size - 8);
   pragma $Build_Warnings (On,  "* bits of ""Per_CPU_Storage"" unused");

   Current_Major_Frame : Skp.Scheduling.Major_Frame_Range;

   -------------------------------------------------------------------------

   function Get_Current_Major_Frame_ID return Skp.Scheduling.Major_Frame_Range
   with
      Refined_Global => (Input => Current_Major_Frame),
      Refined_Post   => Get_Current_Major_Frame_ID'Result = Current_Major_Frame
   is
   begin
      return Current_Major_Frame;
   end Get_Current_Major_Frame_ID;

   -------------------------------------------------------------------------

   function Get_Current_Major_Length return Skp.Scheduling.Minor_Frame_Range
   with
      Refined_Global => (Input => Current_Major_Frame),
      Refined_Post   => Get_Current_Major_Length'Result =
       Skp.Scheduling.Scheduling_Plans (CPU_ID)(Current_Major_Frame).Length
   is
   begin
      return Skp.Scheduling.Scheduling_Plans
        (CPU_ID)(Current_Major_Frame).Length;
   end Get_Current_Major_Length;

   -------------------------------------------------------------------------

   function Get_Current_Minor_Frame return Active_Minor_Frame_Type
   with
      Refined_Global => (Input => Per_CPU_Storage),
      Refined_Post   =>
         Get_Current_Minor_Frame'Result = Per_CPU_Storage.Current_Minor_Frame
   is
   begin
      return Per_CPU_Storage.Current_Minor_Frame;
   end Get_Current_Minor_Frame;

   -------------------------------------------------------------------------

   function Get_Current_Subject_ID return Skp.Subject_Id_Type
   with
      Refined_Global => (Input => Per_CPU_Storage)
   is
   begin
      return Per_CPU_Storage.Current_Minor_Frame.Subject_Id;
   end Get_Current_Subject_ID;

   -------------------------------------------------------------------------

   function Get_Minor_Frame
     (Major_Id : Skp.Scheduling.Major_Frame_Range;
      Minor_Id : Skp.Scheduling.Minor_Frame_Range)
      return Skp.Scheduling.Minor_Frame_Type
   with
      Refined_Global => (Input => Per_CPU_Storage)
   is
   begin
      return Per_CPU_Storage.Scheduling_Plan
        (Major_Id).Minor_Frames (Minor_Id);
   end Get_Minor_Frame;

   -------------------------------------------------------------------------

   function Get_Subject_ID
     (Group : Skp.Scheduling.Scheduling_Group_Range)
      return Skp.Subject_Id_Type
   with
      Refined_Global => (Input => Per_CPU_Storage),
      Refined_Post   =>
       Get_Subject_ID'Result = Per_CPU_Storage.Scheduling_Groups (Group)
   is
   begin
      return Per_CPU_Storage.Scheduling_Groups (Group);
   end Get_Subject_ID;

   -------------------------------------------------------------------------

   procedure Init
   with
      Refined_Global  => (Output => (Current_Major_Frame, Per_CPU_Storage)),
      Refined_Depends => ((Current_Major_Frame, Per_CPU_Storage) => null)
   is
   begin
      Current_Major_Frame := Skp.Scheduling.Major_Frame_Range'First;
      Per_CPU_Storage     := Storage_Type'
        (Scheduling_Plan     => Skp.Scheduling.Null_Major_Frames,
         Scheduling_Groups   => (others => Skp.Subject_Id_Type'First),
         Current_Minor_Frame => Active_Minor_Frame_Type'
           (Minor_Id   => Skp.Scheduling.Minor_Frame_Range'First,
            Subject_Id => Skp.Subject_Id_Type'First));
   end Init;

   -------------------------------------------------------------------------

   function Is_BSP return Boolean
   is
   begin
      --  Skp.CPU_Range is auto-generated by mugenspec and contains only a
      --  single element if the system is configured for one core. GNAT finds
      --  the use of 'First on such a trivial type suspicious and warns about
      --  it.
      pragma Warnings (Off);
      return CPU_ID = Skp.CPU_Range'First;
      pragma Warnings (On);
   end Is_BSP;

   -------------------------------------------------------------------------

   procedure Set_Current_Major_Frame (ID : Skp.Scheduling.Major_Frame_Range)
   with
      Refined_Global  => (Output => Current_Major_Frame),
      Refined_Depends => (Current_Major_Frame => ID),
      Refined_Post    => Current_Major_Frame = ID
   is
   begin
      Current_Major_Frame := ID;
   end Set_Current_Major_Frame;

   -------------------------------------------------------------------------

   procedure Set_Current_Minor (Frame : Active_Minor_Frame_Type)
   with
      Refined_Global  => (In_Out => Per_CPU_Storage),
      Refined_Depends => (Per_CPU_Storage =>+ Frame),
      Refined_Post    => Per_CPU_Storage.Current_Minor_Frame = Frame
   is
   begin
      Per_CPU_Storage.Current_Minor_Frame := Frame;
   end Set_Current_Minor;

   -------------------------------------------------------------------------

   procedure Set_Scheduling_Groups
     (Data : Skp.Scheduling.Scheduling_Group_Array)
   with
      Refined_Global  => (In_Out => Per_CPU_Storage),
      Refined_Depends => (Per_CPU_Storage =>+ Data),
      Refined_Post    => Per_CPU_Storage.Scheduling_Groups = Data
   is
   begin
      Per_CPU_Storage.Scheduling_Groups := Data;
   end Set_Scheduling_Groups;

   -------------------------------------------------------------------------

   procedure Set_Scheduling_Plan (Data : Skp.Scheduling.Major_Frame_Array)
   with
      Refined_Global  => (In_Out => Per_CPU_Storage),
      Refined_Depends => (Per_CPU_Storage =>+ Data),
      Refined_Post    => Per_CPU_Storage.Scheduling_Plan = Data
   is
   begin
      Per_CPU_Storage.Scheduling_Plan := Data;
   end Set_Scheduling_Plan;

   -------------------------------------------------------------------------

   procedure Set_Subject_ID
     (Group      : Skp.Scheduling.Scheduling_Group_Range;
      Subject_ID : Skp.Subject_Id_Type)
   with
      Refined_Global  => (In_Out => Per_CPU_Storage),
      Refined_Depends => (Per_CPU_Storage =>+ (Group, Subject_ID)),
      Refined_Post    => Per_CPU_Storage.Scheduling_Groups (Group) = Subject_ID
   is
   begin
      Per_CPU_Storage.Scheduling_Groups (Group):= Subject_ID;
   end Set_Subject_ID;

   -------------------------------------------------------------------------

   procedure Swap_Subject
     (Old_Id : Skp.Subject_Id_Type;
      New_Id : Skp.Subject_Id_Type)
     with
        Refined_Global  => (In_Out => Per_CPU_Storage),
        Refined_Depends => (Per_CPU_Storage =>+ (Old_Id, New_Id))
   is
   begin
      for I in Skp.Scheduling.Major_Frame_Range loop
         for J in Skp.Scheduling.Minor_Frame_Range loop
            if Per_CPU_Storage.Scheduling_Plan (I).Minor_Frames
              (J).Subject_Id = Old_Id
            then
               Per_CPU_Storage.Scheduling_Plan (I).Minor_Frames
                 (J).Subject_Id := New_Id;
            end if;
         end loop;
      end loop;

      if Per_CPU_Storage.Current_Minor_Frame.Subject_Id = Old_Id then
         Per_CPU_Storage.Current_Minor_Frame.Subject_Id := New_Id;
      end if;
   end Swap_Subject;

end SK.CPU_Global;
