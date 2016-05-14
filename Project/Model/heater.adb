with System;

with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Real_Time;
use Ada.Real_Time;
with Ada.Float_Text_IO;
use Ada.Float_Text_IO;
with Ada.Exceptions;
use Ada.Exceptions;
with Ada.Strings.Unbounded;
use Ada.Strings.Unbounded;
with GNAT.Sockets; use GNAT.Sockets;
with CommonData; use CommonData;

package body Heater is

   task HeaterTask
     with Priority => (System.Default_Priority+1);

   task HeaterSocket
     with Priority => (System.Default_Priority+2);

   task body HeaterSocket is
      Address : Sock_Addr_Type;
      Socket  : Socket_Type;
      Server   : Socket_Type;
      Channel : Stream_Access;
      Temp : Range_Proc_Temp;
      Request : Unbounded_String;
      RequestCommStart : Character := 'R';
      FirstCharacter : Character;
   begin
      Address.Addr := Addresses (Get_Host_By_Name (Host_Name), 1);
      Address.Port := 5002;
      Create_Socket (Server);
      Set_Socket_Option (Server, Socket_Level, (Reuse_Address, True));
      Bind_Socket (Server, Address);
      Listen_Socket (Server);
      Accept_Socket (Server, Socket, Address);
      Channel := Stream (Socket);
      loop
         Append(Request, String'Input (Channel));
         FirstCharacter := To_String(Request)(1);
         if FirstCharacter = RequestCommStart then
            if To_String(Request) = "R:HEAT" then
               Heater_Command := Heat;
               String'Output (Channel, "Ok");
               Put_Line("Heating on");
            elsif To_String(Request) = "R:OFF" then
               Heater_Command := Off;
               String'Output (Channel, "OK");
               Put_Line("Heating off");
            elsif To_String(Request) = "R:RESET" then
               Barrel_Water_Temp.Input(0.0);
               String'Output (Channel, "OK");
               Put_Line("Temp reset");
            else
               Put_Line("Unknown command");
               String'Output (Channel, "Unknown command");
            end if;
         elsif To_String(Request) = "GET" then
            Temp := Barrel_Water_Temp.Output;
            Float'Output (Channel, Temp);
            Put_Line("Send: " & Temp'Img);
         end if;
         Delete(Request, 1, To_String(Request)'Length);
      end loop;
   exception
      when E:others =>
         Close_Socket (Socket);
         Put_Line("Error: Task Heater Server");
         Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
   end HeaterSocket;

   task body HeaterTask is
      Next : Ada.Real_Time.Time;
      Period : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(3000);
      Shift : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(30);
      Temp : Float := 0.0;
      WaterInBarrel : constant Float := 15.0;
      HeatCapacity : constant Float := 4190.0;
      HeaterPower : constant Float := 2000.0;
      Faster : constant Float := 40.0;
   begin
      Next := Ada.Real_Time.Clock + Shift;
      loop
         delay until Next;
         if Heater_Command = Heat then
            Temp := ((HeaterPower * 3.0 * Faster) / (WaterInBarrel * HeatCapacity)) + Barrel_Water_Temp.Output;
            pragma Assert( Temp in Range_Proc_Temp );
            if Temp in Range_Proc_Temp then
               Barrel_Water_Temp.Input( Temp );
            else
               Put_Line("Error: Heating out of permitted range");
            end if;
         end if;
         Next := Next + Period;
      end loop;
   exception
      when E:others =>
         Put_Line("Error: Task Heater");
         Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
   end HeaterTask;

   protected body Shared_Proc_Temp  is
      procedure Input(D: in Range_Proc_Temp) is
      begin
         Data := D;
      end Input;
      procedure Output(D: out Range_Proc_Temp) is
      begin
         D := Data;
      end Output;
      function Output return Range_Proc_Temp is (Data);
      function Image return String is
         Str : String(1..6);
      begin
         Put(To=>Str, Item=>Data,Aft=>2, Exp=>0);
         return Str;
      end Image;
   end Shared_Proc_Temp;

begin
   Barrel_Water_Temp.Input(15.0);
end Heater;
