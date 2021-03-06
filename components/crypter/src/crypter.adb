--
--  Copyright (C) 2013-2015  Reto Buerki <reet@codelabs.ch>
--  Copyright (C) 2013-2015  Adrian-Ken Rueegsegger <ken@codelabs.ch>
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

with X86_64;

with SK.CPU;
with SK.Hypercall;
with SK.Interrupt_Tables;

with Component_Constants;

with Crypt.Receiver;
with Crypt.Sender;
with Crypt.Hasher;

with Crypt.Debug;

with Handler;

procedure Crypter
with
   Global =>
     (Input  => Crypt.Receiver.State,
      Output => Crypt.Sender.State,
      In_Out => (X86_64.State, Handler.Requesting_Subject,
                 SK.Interrupt_Tables.State))
is
   Client_ID : SK.Byte;
   Request   : Crypt.Message_Type;
   Response  : Crypt.Message_Type;
begin
   pragma Debug (Crypt.Debug.Put_Greeter);
   SK.Interrupt_Tables.Initialize
     (Stack_Addr => Component_Constants.Interrupt_Stack_Address);

   SK.CPU.Sti;

   loop
      SK.CPU.Hlt;
      Client_ID := Handler.Requesting_Subject;
      pragma Debug (Crypt.Debug.Put_Process_Message (Client_ID => Client_ID));

      Response := Crypt.Null_Message;
      Crypt.Receiver.Receive (Req => Request);
      pragma Warnings
        (GNATprove, Off, "attribute Valid is assumed to return True",
         Reason => "Current proof limitation of GNATProve");
      if Request.Size'Valid then
         pragma Warnings
           (GNATprove, On, "attribute Valid is assumed to return True");
         pragma Debug (Crypt.Debug.Put_Word16
                       (Message => " Size",
                        Value   => Request.Size));
         Crypt.Hasher.SHA256_Hash (Input  => Request,
                                   Output => Response);
         pragma Debug (Crypt.Debug.Put_Hash (Item => Response));
      end if;
      pragma Debug (not Request.Size'Valid,
                    Crypt.Debug.Put_Word16
                      (Message => "Invalid request message size",
                       Value   => Request.Size));

      Crypt.Sender.Send (Res => Response);
      SK.Hypercall.Trigger_Event (Number => Client_ID);
   end loop;
end Crypter;
