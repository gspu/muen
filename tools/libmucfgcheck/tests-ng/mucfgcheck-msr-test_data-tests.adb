--  This package has been generated automatically by GNATtest.
--  You are allowed to add your code to the bodies of test routines.
--  Such changes will be kept during further regeneration of this file.
--  All code placed outside of test routine bodies will be lost. The
--  code intended to set up and tear down the test environment should be
--  placed into Mucfgcheck.MSR.Test_Data.

with AUnit.Assertions; use AUnit.Assertions;

package body Mucfgcheck.MSR.Test_Data.Tests is


--  begin read only
   procedure Test_Start_Smaller_End (Gnattest_T : in out Test);
   procedure Test_Start_Smaller_End_3ff191 (Gnattest_T : in out Test) renames Test_Start_Smaller_End;
--  id:2.2/3ff19145334275c7/Start_Smaller_End/1/0/
   procedure Test_Start_Smaller_End (Gnattest_T : in out Test) is
   --  mucfgcheck-msr.ads:25:4:Start_Smaller_End
--  end read only

      pragma Unreferenced (Gnattest_T);

   begin

      AUnit.Assertions.Assert
        (Gnattest_Generated.Default_Assert_Value,
         "Test not implemented.");

--  begin read only
   end Test_Start_Smaller_End;
--  end read only


--  begin read only
   procedure Test_Low_Or_High (Gnattest_T : in out Test);
   procedure Test_Low_Or_High_2e4f48 (Gnattest_T : in out Test) renames Test_Low_Or_High;
--  id:2.2/2e4f4877eabfbdff/Low_Or_High/1/0/
   procedure Test_Low_Or_High (Gnattest_T : in out Test) is
   --  mucfgcheck-msr.ads:28:4:Low_Or_High
--  end read only

      pragma Unreferenced (Gnattest_T);

   begin

      AUnit.Assertions.Assert
        (Gnattest_Generated.Default_Assert_Value,
         "Test not implemented.");

--  begin read only
   end Test_Low_Or_High;
--  end read only

end Mucfgcheck.MSR.Test_Data.Tests;
