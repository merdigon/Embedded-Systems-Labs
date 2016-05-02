with System;

with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Real_Time;
use Ada.Real_Time;
with Ada.Float_Text_IO;
use Ada.Float_Text_IO;
with Ada.Exceptions;
use Ada.Exceptions;
with CommonData;
use CommonData;
with Ada.Strings.Unbounded;
use Ada.Strings.Unbounded;
with GNAT.Sockets; use GNAT.Sockets;

package body Pump is

   task PumpTask
     with Priority => (System.Default_Priority+1);

   task PumpSocket
     with Priority => (System.Default_Priority+2);

   task body PumpSocket is
      Address : Sock_Addr_Type;
      Socket  : Socket_Type;
      Server   : Socket_Type;
      Channel : Stream_Access;
      Request : Unbounded_String;
      Water_Level : Range_Proc_Temp := 0.0;
      Curr_Powder_Level : Range_Proc_Temp := 0.0;
      Curr_Liquid_Level : Range_Proc_Temp := 0.0;
      RequestCommStart : Character := 'R';
      FirstCharacter : Character;
   begin
      Address.Addr := Addresses (Get_Host_By_Name (Host_Name), 1);
      Address.Port := 5003;
      Create_Socket (Server);
      Set_Socket_Option (Server, Socket_Level, (Reuse_Address, True));
      Bind_Socket (Server, Address);
      Listen_Socket (Server);
      Accept_Socket (Server, Socket, Address);
      Channel := Stream (Socket);
      loop
         Append(Request, String'Input (Channel));
         FirstCharacter := To_String(Request)(1);
         Put_Line(To_String(Request));
         if FirstCharacter = RequestCommStart then
            if To_String(Request)(1..9) = "R:In:OPEN" then
               Pump_In_Command := Open;
               String'Output (Channel, "Ok");
               if To_String(Request)(To_String(Request)'Length - 6..To_String(Request)'Length) = "POWDER" then
                  Pump_In_Water_Migration := Powder;
               elsif To_String(Request)(To_String(Request)'Length - 6..To_String(Request)'Length) = "NORMAL" then
                  Pump_In_Water_Migration := Normal;
               elsif To_String(Request)(To_String(Request)'Length - 6..To_String(Request)'Length) = "LIQUID" then
                  Pump_In_Water_Migration := Liquid;
               end if;
               Put_Line("Open Pump In -> " & Pump_In_Water_Migration'Img);
            elsif To_String(Request) = "R:In:CLOSE" then
               Pump_In_Command := Close;
               String'Output (Channel, "OK");
               Put_Line("Close Pump In");
            elsif To_String(Request) = "R:Out:OPEN" then
               Pump_Out_Command := Open;
               String'Output (Channel, "OK");
               Put_Line("Open Pump Out");
            elsif To_String(Request) = "R:Out:CLOSE" then
               Pump_Out_Command := Close;
               String'Output (Channel, "OK");
               Put_Line("Close Pump Out");
            else
               Put_Line("Unknown command");
               String'Output (Channel, "Unknown command");
            end if;
         elsif To_String(Request) = "GET" then
            Water_Level := Barrel_Water_Level.Output;
            Float'Output (Channel, Water_Level);
            Put_Line("Send: " & Water_Level'Img);
         elsif To_String(Request) = "GET:POWDER" then
            Curr_Powder_Level := Powder_Level.Output;
            Float'Output (Channel, Curr_Powder_Level);
            Put_Line("Send powder level: " & Curr_Powder_Level'Img);
         elsif To_String(Request) = "GET:LIQUID" then
            Curr_Liquid_Level := Washing_Liquid_Level.Output;
            Float'Output (Channel, Curr_Liquid_Level);
            Put_Line("Send liquid level: " & Curr_Liquid_Level'Img);
         elsif To_String(Request) = "SET:POWDER" then
            Curr_Powder_Level := Float'Input (Channel);
            Powder_Level.Input(Curr_Powder_Level);
            Put_Line("Set powder level on " & Curr_Powder_Level'Img & "%.");
         elsif To_String(Request) = "SET:LIQUID" then
            Curr_Liquid_Level := Float'Input (Channel);
            Washing_Liquid_Level.Input(Curr_Liquid_Level);
            Put_Line("Set liquid level on " & Curr_Liquid_Level'Img & "%.");
         end if;
         Delete(Request, 1, To_String(Request)'Length);
      end loop;
   exception
      when E:others =>
         Close_Socket (Socket);
         Put_Line("Error: Task Pump Server");
         Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
   end PumpSocket;

   task body PumpTask is
      Next : Ada.Real_Time.Time;
      Period : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(1000);
      Shift : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(30);
      Water_Level : Range_Proc_Temp := 0.0;
      Powder_Level_Curr : Range_Proc_Temp := 0.0;
      Liquid_Level_Curr : Range_Proc_Temp := 0.0;
      Powder_Liquid_Outcome : Float := 25.0;
      InOutWaterLevelChange : constant Float := 10.0;
      Previous_Barrel_Command : Barrel_Commands := Off;
   begin
      Next := Ada.Real_Time.Clock + Shift;
      loop
         delay until Next;
         if Pump_In_Command = Open then
            Water_Level := Barrel_Water_Level.Output;
            if (Water_Level + InOutWaterLevelChange) in Range_Proc_Temp then
               Barrel_Water_Level.Input(Water_Level + InOutWaterLevelChange);
            elsif Water_Level < 100.0 then
               Barrel_Water_Level.Input(100.0);
            end if;
            if Pump_In_Water_Migration = Powder then
               Powder_Level_Curr := Powder_Level.Output;
               if (Powder_Level_Curr - Powder_Liquid_Outcome) in Range_Proc_Temp then
                  Powder_Level.Input(Powder_Level_Curr - Powder_Liquid_Outcome);
               elsif Powder_Level_Curr > 0.0 then
                  Powder_Level.Input(0.0);
               end if;
            elsif Pump_In_Water_Migration = Liquid then
               Liquid_Level_Curr := Washing_Liquid_Level.Output;
               if (Liquid_Level_Curr - Powder_Liquid_Outcome) in Range_Proc_Temp then
                  Washing_Liquid_Level.Input(Liquid_Level_Curr - Powder_Liquid_Outcome);
               elsif Liquid_Level_Curr > 0.0 then
                  Washing_Liquid_Level.Input(0.0);
               end if;
            end if;
         elsif Pump_Out_Command = Open then
            Water_Level := Barrel_Water_Level.Output;
            if (Water_Level - InOutWaterLevelChange) in Range_Proc_Temp then
               Barrel_Water_Level.Input(Water_Level - InOutWaterLevelChange);
            elsif Water_Level > 0.0 then
               Barrel_Water_Level.Input(0.0);
            end if;
         end if;
         Next := Next + Period;
      end loop;
   exception
      when E:others =>
         Put_Line("Error: Task Pump");
         Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
   end PumpTask;

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
   Barrel_Water_Level.Input(0.0);
   Pump_In_Water_Migration := Normal;
end Pump;
