--
--  Copyright (C) 2017  Reto Buerki <reet@codelabs.ch>
--  Copyright (C) 2017  Adrian-Ken Rueegsegger <ken@codelabs.ch>
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

with Interfaces;

with SK.CPU;

with Ahci.Constants;
with Ahci.Pciconf;

with Debug_Ops;

procedure Ahci_Drv
is
begin
   pragma Debug (Debug_Ops.Init (Epoch => 1));
   pragma Debug (Debug_Ops.Put_Line (Item => "AHCI driver subject running"));
   pragma Debug (Debug_Ops.Print_PCI_Device_Info);
   pragma Debug (Debug_Ops.Print_PCI_Capabilities);

   declare
      use type Interfaces.Unsigned_24;

      Class_Code : constant Interfaces.Unsigned_24
        := Ahci.Pciconf.Instance.Header.Class_Code;
   begin
      if Class_Code = Ahci.Constants.AHCI_Class_Code then
         pragma Debug (Debug_Ops.Put_Line (Item => "AHCI controller present"));
         pragma Debug (Debug_Ops.Print_HBA_Memory_Regs);
         SK.CPU.Stop;
      end if;
   end;

   SK.CPU.Stop;
end Ahci_Drv;
