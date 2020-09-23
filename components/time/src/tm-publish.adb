--
--  Copyright (C) 2015  Reto Buerki <reet@codelabs.ch>
--  Copyright (C) 2015  Adrian-Ken Rueegsegger <ken@codelabs.ch>
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

with Interfaces;

with Time_Component.Channel_Arrays;

package body Tm.Publish
with
   Refined_State => (State => Time_Export)
is

   package Cspecs renames Time_Component.Channel_Arrays;

   type Padding_Type is array
     (Mutime.Info.Time_Info_Size + 1 .. Cspecs.Export_Channels_Element_Size)
     of Interfaces.Unsigned_8
   with
      Size =>
        (Cspecs.Export_Channels_Element_Size - Mutime.Info.Time_Info_Size) * 8;

   type Time_Info_Page is record
      Data    : Mutime.Info.Time_Info_Type;
      Padding : Padding_Type;
   end record
   with
      Size => Cspecs.Export_Channels_Element_Size * 8;

   type Time_Info_Array is array (1 .. Cspecs.Export_Channels_Element_Count)
     of Time_Info_Page
       with
         Size           => Cspecs.Export_Channels_Element_Size
           * Cspecs.Export_Channels_Element_Count * 8,
         Object_Size    => Cspecs.Export_Channels_Element_Size
           * Cspecs.Export_Channels_Element_Count * 8,
         Component_Size => Cspecs.Export_Channels_Element_Size * 8;

   Time_Export : Time_Info_Array
     with
       Volatile,
       Async_Readers,
       Effective_Writes,
       Address => System'To_Address (Cspecs.Export_Channels_Address_Base);

   -------------------------------------------------------------------------

   procedure Update
     (TSC_Time_Base : Mutime.Timestamp_Type;
      TSC_Tick_Rate : Mutime.Info.TSC_Tick_Rate_Hz_Type;
      Timezone      : Mutime.Info.Timezone_Type)
   is
   begin
      for T of Time_Export loop
         T := (Data    => Mutime.Info.Time_Info_Type'
                 (TSC_Time_Base      => TSC_Time_Base,
                  TSC_Tick_Rate_Hz   => TSC_Tick_Rate,
                  Timezone_Microsecs => Timezone),
               Padding => (others => 0));
      end loop;
   end Update;

begin
   for T of Time_Export loop
      T := (Data    => Mutime.Info.Time_Info_Type'
              (TSC_Time_Base      => Mutime.Epoch_Timestamp,
               TSC_Tick_Rate_Hz   => 1000000,
               Timezone_Microsecs => 0),
            Padding => (others => 0));
   end loop;
end Tm.Publish;
