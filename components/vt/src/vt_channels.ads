--
--  Copyright (C) 2013-2017  Reto Buerki <reet@codelabs.ch>
--  Copyright (C) 2013-2017  Adrian-Ken Rueegsegger <ken@codelabs.ch>
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

with Muchannel_Constants;
with Muchannel.Readers;

with Vt_Component.Channel_Arrays;

package VT_Channels
is

   package Cspecs renames Vt_Component.Channel_Arrays;

   package VT_Channel is new Muchannel
     (Element_Type => Character,
      Elements     => Cspecs.Console_Element_Size -
        Muchannel_Constants.Header_Size,
      Null_Element => ASCII.NUL,
      Protocol     => 1);
   package VT_Channel_Rdr is new VT_Channel.Readers;

end VT_Channels;
