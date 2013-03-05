with System.Storage_Elements;

with SK.Console;
with SK.Console_VGA;

package body SK.Subject
is

   --# hide SK.Subject;

   package Text_IO is new SK.Console
     (Initialize      => Console_VGA.Init,
      Output_New_Line => Console_VGA.New_Line,
      Output_Char     => Console_VGA.Put_Char);

   Greeter : constant String := "Hello from guest world";

   -------------------------------------------------------------------------

   procedure Main
   is
      Counter : SK.Word32 := 0;
      Idx     : Positive  := 1;
      Dlt     : Integer   := -1;
   begin
      Text_IO.Init;
      Text_IO.Put_Line (Item => Greeter);
      Text_IO.New_Line;

      for I in Greeter'Range loop
         Text_IO.Put_Char (Item => Character'Val (176));
      end loop;

      while True loop
         if Counter mod 2**19 = 0 then
            Console_VGA.Set_Position (X => Integer (Idx - Dlt),
                                      Y => 3);
            Text_IO.Put_Char (Item => Character'Val (176));
            if Idx = Greeter'Last then
               Dlt := -1;
            elsif Idx = Greeter'First then
               Dlt := 1;
            end if;
            Console_VGA.Set_Position (X => Integer (Idx),
                                      Y => 3);
            Text_IO.Put_Char (Item => Character'Val (178));
            Idx := Idx + Dlt;
         end if;
         Counter := Counter + 1;
      end loop;

      CPU.Panic;
   end Main;

begin
   Descriptors (Descriptors'First)
     := Subject_State_Type'
       (Regs        => CPU.Null_Regs,
        Entry_Point => SK.Word64
          (System.Storage_Elements.To_Integer
             (Value => Main'Address)));
end SK.Subject;
