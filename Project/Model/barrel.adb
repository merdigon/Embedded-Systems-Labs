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

package body Barrel is

   task BarrelTask
     with Priority => (System.Default_Priority+1);

   task BarrelSocket
     with Priority => (System.Default_Priority+2);

   task body BarrelSocket is
      Address : Sock_Addr_Type;
      Socket  : Socket_Type;
      Server   : Socket_Type;
      Channel : Stream_Access;
      Request : Unbounded_String;
      Dire : Direction;
      Speed : Float;
      RequestCommStart : Character := 'R';
      FirstCharacter : Character;
   begin
      Address.Addr := Addresses (Get_Host_By_Name (Host_Name), 1);
      Address.Port := 5001;
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
            if To_String(Request) = "R:SLOWTWOWAY" then
               Barrel_Command := SlowTwoWay;
               String'Output (Channel, "OK");
               Put_Line("Slow Two Way Spin");
            elsif To_String(Request) = "R:SPIN" then
               Barrel_Command := Spin;
               String'Output (Channel, "OK");
               Put_Line("Fast spinning");
            elsif To_String(Request) = "R:OFF" then
               Barrel_Command := Off;
               String'Output (Channel, "OK");
               Put_Line("Barrel off");
            else
               Put_Line("Unknown command");
               String'Output (Channel, "Unknown command");
            end if;
         elsif To_String(Request) = "GET" then
            Dire := Barrel_Rotation.OutputDirection;
            Speed := Barrel_Rotation.OutputSpeed;
            Float'Output (Channel, Speed);
            String'Output (Channel, Dire'Img);
            Put_Line("Send: " & Speed'Img & ":" & Dire'Img);
         end if;
         Delete(Request, 1, To_String(Request)'Length);
      end loop;
   exception
      when E:others =>
         Close_Socket (Socket);
         Put_Line("Error: Task Barrel Server");
         Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
   end BarrelSocket;

   task body BarrelTask is
      Next : Ada.Real_Time.Time;
      Period : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(1000);
      Shift : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(30);
      OneSideSpinStart : Ada.Real_Time.Time;
      PeriodOfOneSideSpin : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(10000);
      Dire : Direction;
      Speed : Float;
      MaxSpinSpeed : constant Float := 160.0;
      MaxSpinIncome : constant Float := 40.0;
      MaxSlowSpeed : constant Float := 20.0;
      MaxSlowIncome : constant Float := 5.0;
      Previous_Barrel_Command : Barrel_Commands := Off;
   begin
      Next := Ada.Real_Time.Clock + Shift;
      loop
         delay until Next;
         if Barrel_Command = Spin then
            if Previous_Barrel_Command = Off then
               Barrel_Rotation.Input(Left);
               Previous_Barrel_Command := Spin;
            end if;
            Speed := MaxSpinIncome + Barrel_Rotation.OutputSpeed;
            if Speed <= MaxSpinSpeed then
               Barrel_Rotation.Input( Speed );
            end if;
         elsif Barrel_Command = SlowTwoWay then
            Speed := Barrel_Rotation.OutputSpeed;
            if Previous_Barrel_Command = Off then
               Barrel_Rotation.Input(Left);
               Barrel_Rotation.Input(Speed + MaxSlowIncome);
               Previous_Barrel_Command := SlowTwoWay;
               OneSideSpinStart := Ada.Real_Time.Clock + Shift;
            elsif Speed = 0.0 then
               Dire := Barrel_Rotation.OutputDirection;
               if Dire = Left then
                  Barrel_Rotation.Input(Right);
               else
                  Barrel_Rotation.Input(Left);
               end if;
               Barrel_Rotation.Input(MaxSlowIncome);
               OneSideSpinStart := Ada.Real_Time.Clock + Shift;
            elsif (Ada.Real_Time.Clock - PeriodOfOneSideSpin) > OneSideSpinStart then
               Speed := Speed - MaxSlowIncome;
               if Speed < 0.0 then
                  Barrel_Rotation.Input(0.0);
               else
                  Barrel_Rotation.Input(Speed);
               end if;
            elsif Speed < MaxSlowSpeed then
               Speed := Speed + MaxSlowIncome;
               if Speed > MaxSlowSpeed then
                  Barrel_Rotation.Input(MaxSlowSpeed);
               else
                  Barrel_Rotation.Input(Speed);
               end if;
            end if;
         elsif Barrel_Command = Off then
            Speed := Barrel_Rotation.OutputSpeed;
            if Speed > 0.0 then
               if Previous_Barrel_Command = Spin then
                  Speed := Speed - MaxSpinIncome;
               else
                  Speed := Speed - MaxSlowIncome;
               end if;
               if Speed < 0.0 then
                  Barrel_Rotation.Input(0.0);
               else
                  Barrel_Rotation.Input(Speed);
               end if;
            elsif Previous_Barrel_Command /= Off then
               Previous_Barrel_Command := Off;
            end if;
         end if;
         Next := Next + Period;
      end loop;
   exception
      when E:others =>
         Put_Line("Error: Task Barrel");
         Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
   end BarrelTask;

   protected body Shared_Rotation  is
      procedure Input(S: in Float; D: in Direction) is
      begin
         Speed := S;
         Dire := D;
      end Input;
      procedure Input(D: in Direction) is
      begin
         Dire := D;
      end Input;
      procedure Input(S: in Float) is
      begin
         Speed := S;
      end Input;
      procedure Output(S: out Float; D: out Direction) is
      begin
         S := Speed;
         D := Dire;
      end Output;
      procedure Output(S: out Float) is
      begin
         S := Speed;
      end Output;
      procedure Output(D: out Direction) is
      begin
         D := Dire;
      end Output;
      function OutputSpeed return Float is (Speed);
      function OutputDirection return Direction is (Dire);
      function ImageSpeed return String is
         Str : String(1..6);
      begin
         Put(To=>Str, Item=>Speed,Aft=>2, Exp=>0);
         return Str;
      end ImageSpeed;
      function ImageDirection return String is
      begin
         if Dire = Left then
            return "Left";
         else
            return "Right";
         end if;
      end ImageDirection;
   end Shared_Rotation;


begin
   Barrel_Rotation.Input(0.0);
end Barrel;
