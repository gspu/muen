--
--  Copyright (C) 2014  Reto Buerki <reet@codelabs.ch>
--  Copyright (C) 2014  Adrian-Ken Rueegsegger <ken@codelabs.ch>
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

with Ada.Strings.Fixed;

with Interfaces;

with DOM.Core.Nodes;
with DOM.Core.Elements;

with McKae.XML.XPath.XIA;

with Mulog;
with Muxml.Utils;
with Mutools.Constants;

package body Validators.Memory
is

   use McKae.XML.XPath.XIA;

   -------------------------------------------------------------------------

   procedure Physical_Address_Alignment (XML_Data : Muxml.XML_Data_Type)
   is
      use type Interfaces.Unsigned_64;

      Nodes : constant DOM.Core.Node_List := XPath_Query
        (N     => XML_Data.Doc,
         XPath => "//*[@physicalAddress]");
   begin
      Mulog.Log (Msg => "Checking alignment of" & DOM.Core.Nodes.Length
                 (List => Nodes)'Img & " physical addresses");

      for I in 0 .. DOM.Core.Nodes.Length (List => Nodes) - 1 loop
         declare
            Node     : constant DOM.Core.Node
              := DOM.Core.Nodes.Item (List  => Nodes,
                                      Index => I);
            Name     : constant String := DOM.Core.Elements.Get_Attribute
              (Elem => Node,
               Name => "name");
            Addr_Str : constant String := DOM.Core.Elements.Get_Attribute
              (Elem => Node,
               Name => "physicalAddress");
            Address  : constant Interfaces.Unsigned_64
              := Interfaces.Unsigned_64'Value (Addr_Str);
         begin
            if Address mod Mutools.Constants.Page_Size /= 0 then
               raise Validation_Error with "Physical address " & Addr_Str
                 & " of '" & Name & "' not page aligned";
            end if;
         end;
      end loop;
   end Physical_Address_Alignment;

   -------------------------------------------------------------------------

   procedure Physical_Memory_References (XML_Data : Muxml.XML_Data_Type)
   is
      Nodes : constant DOM.Core.Node_List := XPath_Query
        (N     => XML_Data.Doc,
         XPath => "//physical");
   begin
      Mulog.Log (Msg => "Checking" & DOM.Core.Nodes.Length (List => Nodes)'Img
                 & " physical memory references");

      for I in 0 .. DOM.Core.Nodes.Length (List => Nodes) - 1 loop
         declare
            Node         : constant DOM.Core.Node
              := DOM.Core.Nodes.Item (List  => Nodes,
                                      Index => I);
            Logical_Name : constant String
              := DOM.Core.Elements.Get_Attribute
                (Elem => DOM.Core.Nodes.Parent_Node (N => Node),
                 Name => "logical");
            Phys_Name    : constant String
              := DOM.Core.Elements.Get_Attribute
                (Elem => Node,
                 Name => "name");
            Physical     : constant DOM.Core.Node_List
              := XPath_Query
                (N     => XML_Data.Doc,
                 XPath => "/system/memory/memory[@name='" & Phys_Name & "']");
         begin
            if DOM.Core.Nodes.Length (List => Physical) = 0 then
               raise Validation_Error with "Physical memory '" & Phys_Name
                 & "' referenced by logical memory '" & Logical_Name
                 & "' not found";
            end if;
         end;
      end loop;
   end Physical_Memory_References;

   -------------------------------------------------------------------------

   procedure Region_Size (XML_Data : Muxml.XML_Data_Type)
   is
      use type Interfaces.Unsigned_64;

      Nodes : constant DOM.Core.Node_List := XPath_Query
        (N     => XML_Data.Doc,
         XPath => "//*[@size]");
   begin
      Mulog.Log (Msg => "Checking" & DOM.Core.Nodes.Length
                 (List => Nodes)'Img & " memory region sizes");

      for I in 0 .. DOM.Core.Nodes.Length (List => Nodes) - 1 loop
         declare
            Node     : constant DOM.Core.Node
              := DOM.Core.Nodes.Item (List  => Nodes,
                                      Index => I);
            Name     : constant String := DOM.Core.Elements.Get_Attribute
              (Elem => Node,
               Name => "name");
            Size_Str : constant String := DOM.Core.Elements.Get_Attribute
              (Elem => Node,
               Name => "size");
            Size     : constant Interfaces.Unsigned_64
              := Interfaces.Unsigned_64'Value (Size_Str);
         begin
            if Size mod Mutools.Constants.Page_Size /= 0 then
               raise Validation_Error with "Size " & Size_Str
                 & " of memory region '" & Name & "' not multiple of page"
                 & " size (4K)";
            end if;
         end;
      end loop;
   end Region_Size;

   -------------------------------------------------------------------------

   procedure Virtual_Address_Alignment (XML_Data : Muxml.XML_Data_Type)
   is
      use type Interfaces.Unsigned_64;

      Nodes : constant DOM.Core.Node_List := XPath_Query
        (N     => XML_Data.Doc,
         XPath => "//*[@virtualAddress]");
   begin
      Mulog.Log (Msg => "Checking alignment of" & DOM.Core.Nodes.Length
                 (List => Nodes)'Img & " virtual addresses");

      for I in 0 .. DOM.Core.Nodes.Length (List => Nodes) - 1 loop
         declare
            Node     : constant DOM.Core.Node
              := DOM.Core.Nodes.Item (List  => Nodes,
                                      Index => I);
            Name     : constant String := DOM.Core.Elements.Get_Attribute
              (Elem => Node,
               Name => "logical");
            Addr_Str : constant String := DOM.Core.Elements.Get_Attribute
              (Elem => Node,
               Name => "virtualAddress");
            Address  : constant Interfaces.Unsigned_64
              := Interfaces.Unsigned_64'Value (Addr_Str);
         begin
            if Address mod Mutools.Constants.Page_Size /= 0 then
               raise Validation_Error with "Virtual address " & Addr_Str
                 & " of '" & Name & "' not page aligned";
            end if;
         end;
      end loop;
   end Virtual_Address_Alignment;

   -------------------------------------------------------------------------

   procedure VMXON_Region_Presence (XML_Data : Muxml.XML_Data_Type)
   is
      CPU_Count : constant Positive := Positive'Value
        (Muxml.Utils.Get_Attribute
           (Doc   => XML_Data.Doc,
            XPath => "/system/platform/processor",
            Name  => "logicalCpus"));
      Mem_Node  : DOM.Core.Node_List;
   begin
      Mulog.Log (Msg => "Checking presence of" & CPU_Count'Img
                 & " VMXON region(s)");

      for I in 0 .. CPU_Count - 1 loop
         declare
            CPU_Str  : constant String
              := Ada.Strings.Fixed.Trim
                (Source => I'Img,
                 Side   => Ada.Strings.Left);
            Mem_Name : constant String
              := "kernel_" & CPU_Str & "|vmxon";
         begin
            Mem_Node := XPath_Query
              (N     => XML_Data.Doc,
               XPath => "/system/memory/memory[@name='" & Mem_Name & "']");
            if DOM.Core.Nodes.Length (List => Mem_Node) = 0 then
               raise Validation_Error with "VMXON region '" & Mem_Name
                 & "' for logical CPU " & CPU_Str & " not found";
            end if;
         end;
      end loop;
   end VMXON_Region_Presence;

   -------------------------------------------------------------------------

   procedure VMXON_Region_Size (XML_Data : Muxml.XML_Data_Type)
   is
      use type Interfaces.Unsigned_64;

      Nodes : constant DOM.Core.Node_List := XPath_Query
        (N     => XML_Data.Doc,
         XPath => "/system/memory/memory[contains(string(@name), '|vmxon')]");
   begin
      Mulog.Log (Msg => "Checking size of" & DOM.Core.Nodes.Length
                 (List => Nodes)'Img & " VMXON region(s)");

      for I in 0 .. DOM.Core.Nodes.Length (List => Nodes) - 1 loop
         declare
            Node     : constant DOM.Core.Node
              := DOM.Core.Nodes.Item (List  => Nodes,
                                      Index => I);
            Name     : constant String
              := DOM.Core.Elements.Get_Attribute
                (Elem => Node,
                 Name => "name");
            Size_Str : constant String
              := DOM.Core.Elements.Get_Attribute
                (Elem => Node,
                 Name => "size");
            Size     : constant Interfaces.Unsigned_64
              := Interfaces.Unsigned_64'Value (Size_Str);
         begin
            if Size /= Mutools.Constants.Page_Size then
               raise Validation_Error with "Size " & Size_Str
                 & " of VMXON memory region '" & Name & "' not 4K";
            end if;
         end;
      end loop;
   end VMXON_Region_Size;

end Validators.Memory;