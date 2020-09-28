--
--  Copyright (C) 2014, 2015  Reto Buerki <reet@codelabs.ch>
--  Copyright (C) 2014, 2015  Adrian-Ken Rueegsegger <ken@codelabs.ch>
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

with SK.Strings;

with Debuglog.Client;

with Ahci.Pciconf;
with Ahci.Registers;

package body Debug_Ops
with
   SPARK_Mode => Off
is

   -------------------------------------------------------------------------

   procedure Init
     (Epoch : Interfaces.Unsigned_64)
      renames Debuglog.Client.Init;

   -------------------------------------------------------------------------

   procedure Print_HBA_Memory_Regs
   is
      use Ahci.Registers;

      Dummy32 : Interfaces.Unsigned_32;
   begin
      Put_Line (Item => "HBA Memory Registers");
      Dummy32 := Instance.Host_Capabilities;
      Put_Line (Item => " Host Caps : " & SK.Strings.Img (Dummy32));
   end Print_HBA_Memory_Regs;

   -------------------------------------------------------------------------

   procedure Print_PCI_Capabilities
   is
      use type Interfaces.Unsigned_8;
      use Ahci.Pciconf;

      Cap_ID : Interfaces.Unsigned_8;
      Index  : Interfaces.Unsigned_8 := Instance.Header.Capabilities_Pointer;
   begin
      loop
         exit when Index = 0 or not (Index in Ahci.Pciconf.Capability_Range);
         Cap_ID := Instance.Capabilities (Index);
         Put_Line (Item => "Capability : " & SK.Strings.Img (Cap_ID) & " @ "
                     & SK.Strings.Img (Index));
         Index := Instance.Capabilities (Index + 1);
      end loop;
   end Print_PCI_Capabilities;

   -------------------------------------------------------------------------

   procedure Print_PCI_Device_Info
   is
      use Ahci.Pciconf;

      Dummy8  : Interfaces.Unsigned_8;
      Dummy16 : Interfaces.Unsigned_16;
      Dummy32 : Interfaces.Unsigned_32;
   begin
      Dummy16 := Instance.Header.Vendor_ID;
      Put_Line (Item => "Vendor ID  : " & SK.Strings.Img (Dummy16));
      Dummy16 := Instance.Header.Device_ID;
      Put_Line (Item => "Device ID  : " & SK.Strings.Img (Dummy16));
      Dummy8 := Instance.Header.Revision_ID;
      Put_Line (Item => "Revision   : " & SK.Strings.Img (Dummy8));
      Dummy32 := Interfaces.Unsigned_32 (Instance.Header.Class_Code);
      Put_Line (Item => "Class      : " & SK.Strings.Img (Dummy32));
   end Print_PCI_Device_Info;

   -------------------------------------------------------------------------

   procedure Put_Line (Item : String) renames Debuglog.Client.Put_Line;

   -------------------------------------------------------------------------

   procedure Put_String (Item : String) renames Debuglog.Client.Put;

end Debug_Ops;
