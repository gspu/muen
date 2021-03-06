--  This package is intended to set up and tear down  the test environment.
--  Once created by GNATtest, this package will never be overwritten
--  automatically. Contents of this package can be modified in any way
--  except for sections surrounded by a 'read only' marker.

with AUnit.Test_Fixtures;

with Ada.Exceptions;
with Ada.Streams.Stream_IO;

with Mutools.Files;

with Paging.Entries;

with Test_Utils;

package Paging.IA32e.Test_Data is

--  begin read only
   type Test is new AUnit.Test_Fixtures.Test_Fixture
--  end read only
   with null record;

   procedure Set_Up (Gnattest_T : in out Test);
   procedure Tear_Down (Gnattest_T : in out Test);

   Ref_PML4_Entry : constant Entries.Table_Entry_Type
     := Entries.Create
       (Dst_Index   => 0,
        Dst_Address => 16#001f_1000#,
        Readable    => True,
        Writable    => True,
        Executable  => True,
        Maps_Page   => False,
        Global      => False,
        Caching     => WC);

   Ref_PDPT_Entry : constant Entries.Table_Entry_Type
     := Entries.Create
       (Dst_Index   => 0,
        Dst_Address => 16#001f_2000#,
        Readable    => True,
        Writable    => True,
        Executable  => True,
        Maps_Page   => False,
        Global      => False,
        Caching     => UC);

   Ref_PD_Entry   : constant Entries.Table_Entry_Type
     := Entries.Create
       (Dst_Index   => 0,
        Dst_Address => 16#001f_3000#,
        Readable    => True,
        Writable    => True,
        Executable  => True,
        Maps_Page   => False,
        Global      => False,
        Caching     => UC);

   Ref_PT_Entry_0 : constant Entries.Table_Entry_Type
     := Entries.Create
       (Dst_Index   => 0,
        Dst_Address => 16#0024_0000#,
        Readable    => True,
        Writable    => True,
        Executable  => True,
        Maps_Page   => True,
        Global      => False,
        Caching     => WB);

   Ref_PT_Entry_256 : constant Entries.Table_Entry_Type
     := Entries.Create
       (Dst_Index   => 0,
        Dst_Address => 16#001f_f000#,
        Readable    => True,
        Writable    => False,
        Executable  => False,
        Maps_Page   => True,
        Global      => False,
        Caching     => UC);

end Paging.IA32e.Test_Data;
