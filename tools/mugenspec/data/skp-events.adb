--  Disable line length check
pragma Style_Checks ("-m");

package body Skp.Events
is

   type Trap_Table_Type is array (Trap_Range) of Source_Event_Type;

   Null_Trap_Table : constant Trap_Table_Type := Trap_Table_Type'
     (others => Null_Source_Event);

   type Source_Event_Table_Type is array (Event_Range) of Source_Event_Type;

   Null_Source_Event_Table : constant Source_Event_Table_Type
     := Source_Event_Table_Type'(others => Null_Source_Event);

   type Target_Event_Table_Type is array (Event_Range) of Target_Event_Type;

   Null_Target_Event_Table : constant Target_Event_Table_Type
     := Target_Event_Table_Type'(others => Null_Target_Event);

   type Subject_Events_Type is record
      Source_Traps  : Trap_Table_Type;
      Source_Events : Source_Event_Table_Type;
      Target_Events : Target_Event_Table_Type;
   end record;

   type Subjects_Events_Array is array (Global_Subject_ID_Type)
     of Subject_Events_Type;

   Subject_Events : constant Subjects_Events_Array := Subjects_Events_Array'(
      0 => Subject_Events_Type'(
       Source_Traps  => Trap_Table_Type'(
          00 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 2,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          48 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 2,
            Target_Event   => 1,
            Handover       => True,
            Send_IPI       => False),
          others => Null_Source_Event),
       Source_Events => Source_Event_Table_Type'(
          17 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 1,
            Target_Event   => 0,
            Handover       => False,
            Send_IPI       => True),
          18 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 2,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          19 => Source_Event_Type'(
            Source_Action  => System_Reboot,
            Target_Subject => Skp.Invalid_Subject,
            Target_Event   => Invalid_Target_Event,
            Handover       => False,
            Send_IPI       => False),
          others => Null_Source_Event),
       Target_Events => Target_Event_Table_Type'(
          0 => Target_Event_Type'(
            Kind   => Inject_Interrupt,
            Vector => 32),
          others => Null_Target_Event)),
      1 => Subject_Events_Type'(
       Source_Traps  => Null_Trap_Table,
       Source_Events => Null_Source_Event_Table,
       Target_Events => Target_Event_Table_Type'(
          0 => Target_Event_Type'(
            Kind   => Inject_Interrupt,
            Vector => 32),
          others => Null_Target_Event)),
      2 => Subject_Events_Type'(
       Source_Traps  => Trap_Table_Type'(
          00 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          02 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          03 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          04 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          05 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          06 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          08 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          09 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          10 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          11 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          12 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          13 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          14 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          15 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          16 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          17 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          18 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          19 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          20 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          21 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          22 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          23 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          24 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          25 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          26 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          27 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          28 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          29 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          30 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          31 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          32 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          33 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          34 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          36 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          37 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          39 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          40 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          41 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          43 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          44 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          45 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          46 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          47 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          48 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          49 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          50 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          51 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          53 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          54 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          55 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          56 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          57 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          58 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          59 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 0,
            Target_Event   => 0,
            Handover       => True,
            Send_IPI       => False),
          others => Null_Source_Event),
       Source_Events => Source_Event_Table_Type'(
          1 => Source_Event_Type'(
            Source_Action  => No_Action,
            Target_Subject => 2,
            Target_Event   => 2,
            Handover       => False,
            Send_IPI       => False),
          others => Null_Source_Event),
       Target_Events => Target_Event_Table_Type'(
          0 => Target_Event_Type'(
            Kind   => No_Action,
            Vector => Invalid_Vector),
          1 => Target_Event_Type'(
            Kind   => Inject_Interrupt,
            Vector => 12),
          2 => Target_Event_Type'(
            Kind   => Reset,
            Vector => Invalid_Vector),
          others => Null_Target_Event)),
      3 => Subject_Events_Type'(
       Source_Traps  => Null_Trap_Table,
       Source_Events => Null_Source_Event_Table,
       Target_Events => Null_Target_Event_Table));

   -------------------------------------------------------------------------

   function Get_Source_Event
     (Subject_ID : Global_Subject_ID_Type;
      Event_Nr   : Event_Range)
      return Source_Event_Type
   is (Subject_Events (Subject_ID).Source_Events (Event_Nr));

   -------------------------------------------------------------------------

   function Get_Target_Event
     (Subject_ID : Global_Subject_ID_Type;
      Event_Nr   : Event_Range)
      return Target_Event_Type
   is (Subject_Events (Subject_ID).Target_Events (Event_Nr));

   -------------------------------------------------------------------------

   function Get_Trap
     (Subject_ID : Global_Subject_ID_Type;
      Trap_Nr    : Trap_Range)
      return Source_Event_Type
   is (Subject_Events (Subject_ID).Source_Traps (Trap_Nr));

end Skp.Events;
