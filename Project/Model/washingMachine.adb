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

package body WashingMachine is

   task ModelTask
     with Priority => (System.Default_Priority+1);

   task BarrelReceiver
     with Priority => (System.Default_Priority+2);

   task HeaterReceiver
     with Priority => (System.Default_Priority+3);

   task PumpReceiver
     with Priority => (System.Default_Priority+4);


   --------------------------------------------------------------------
   --MAIN PROCEDURE

   task body ModelTask is
      Next : Ada.Real_Time.Time;
	  MaxTempInBarrel : Float := 55.0;
      Period : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(1000);
      Shift : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(30);
      WaitingTime : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(500);
      WaitingStopper : Ada.Real_Time.Time;
      FirstSlowSpinTime : Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(20000);
      SecondSlowSpinTime : Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(20000);
      FastSpinTime : Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(10000);
      ThirdSlowSpinTime : Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(20000);
   begin
      Next := Ada.Real_Time.Clock + Shift;
      loop
         delay until Next;
         if Washing_State = Starting then
            if Door_Closed.Output then
				case Choosen_Washing_Type is
					when ECO =>
						FirstSlowSpinTime := Ada.Real_Time.Milliseconds(10000);
						SecondSlowSpinTime := Ada.Real_Time.Milliseconds(10000);
						FastSpinTime := Ada.Real_Time.Milliseconds(5000);
						ThirdSlowSpinTime := Ada.Real_Time.Milliseconds(10000);
						MaxTempInBarrel := 25.0;
					when Normal =>
						FirstSlowSpinTime := Ada.Real_Time.Milliseconds(20000);
						SecondSlowSpinTime := Ada.Real_Time.Milliseconds(20000);
						FastSpinTime := Ada.Real_Time.Milliseconds(1000);
						ThirdSlowSpinTime := Ada.Real_Time.Milliseconds(20000);
						MaxTempInBarrel := 55.0;
					when Extended =>
						FirstSlowSpinTime := Ada.Real_Time.Milliseconds(40000);
						SecondSlowSpinTime := Ada.Real_Time.Milliseconds(40000);
						FastSpinTime := Ada.Real_Time.Milliseconds(2000);
						ThirdSlowSpinTime := Ada.Real_Time.Milliseconds(40000);
						MaxTempInBarrel := 85.0;
				end case;	
               Door_Blocked.Input(true);
               Washing_State := FirstSlowSpin;
            end if;
         elsif Washing_State = FirstSlowSpin then
            Pump_In_Water_Migration := Powder;
            Pump_In_Command := Open;
            WaitingStopper := Ada.Real_Time.Clock + Shift;
            while Barrel_Water_Level.Output < 90.0 loop
               delay until WaitingStopper;
               WaitingStopper := Ada.Real_Time.Clock + WaitingTime;
            end loop;
            Pump_In_Command := Close;
            Barrel_Command := SlowTwoWay;
            Heater_Command := Heat;
            WaitingStopper := Ada.Real_Time.Clock + Shift;
            while Barrel_Water_Temp.Output < MaxTempInBarrel loop
               delay until WaitingStopper;
               WaitingStopper := Ada.Real_Time.Clock + WaitingTime;
            end loop;
            Heater_Command := Off;
            WaitingStopper := Ada.Real_Time.Clock + FirstSlowSpinTime;
            delay until WaitingStopper;
            Barrel_Command := Off;
            Pump_Out_Command := Open;
            WaitingStopper := Ada.Real_Time.Clock + Shift;
            while Barrel_Water_Level.Output /= 0.0 loop
               delay until WaitingStopper;
               WaitingStopper := Ada.Real_Time.Clock + WaitingTime;
            end loop;
            Pump_Out_Command := Close;
            Washing_State := SecondSlowSpin;
         elsif Washing_State = SecondSlowSpin then
            Pump_In_Water_Migration := Normal;
            Pump_In_Command := Open;
            WaitingStopper := Ada.Real_Time.Clock + Shift;
            while Barrel_Water_Level.Output < 90.0 loop
               delay until WaitingStopper;
               WaitingStopper := Ada.Real_Time.Clock + WaitingTime;
            end loop;
            Pump_In_Command := Close;
            Barrel_Command := SlowTwoWay;
            WaitingStopper := Ada.Real_Time.Clock + SecondSlowSpinTime;
            delay until WaitingStopper;
            Barrel_Command := Off;
            Pump_Out_Command := Open;
            WaitingStopper := Ada.Real_Time.Clock + Shift;
            while Barrel_Water_Level.Output /= 0.0 loop
               delay until WaitingStopper;
               WaitingStopper := Ada.Real_Time.Clock + WaitingTime;
            end loop;
            Pump_Out_Command := Close;
            Washing_State := Spin;
         elsif Washing_State = Spin then
            Pump_Out_Command := Open;
            Barrel_Command := Spin;
            WaitingStopper := Ada.Real_Time.Clock + FastSpinTime;
            delay until WaitingStopper;
            Barrel_Command := Off;
            Pump_Out_Command := Close;
            Washing_State := ThirdSlowSpin;
         elsif Washing_State = ThirdSlowSpin then
            Pump_In_Water_Migration := Liquid;
            Pump_In_Command := Open;
            WaitingStopper := Ada.Real_Time.Clock + Shift;
            while Barrel_Water_Level.Output < 90.0 loop
               delay until WaitingStopper;
               WaitingStopper := Ada.Real_Time.Clock + WaitingTime;
            end loop;
            Pump_In_Command := Close;
            Barrel_Command := SlowTwoWay;
            WaitingStopper := Ada.Real_Time.Clock + ThirdSlowSpinTime;
            delay until WaitingStopper;
            Barrel_Command := Off;
            Pump_Out_Command := Open;
            WaitingStopper := Ada.Real_Time.Clock + Shift;
            while Barrel_Water_Level.Output /= 0.0 loop
               delay until WaitingStopper;
               WaitingStopper := Ada.Real_Time.Clock + WaitingTime;
            end loop;
            Pump_Out_Command := Close;
            Washing_State := Ending;
         elsif Washing_State = Ending then
            Door_Blocked.Input(false);
			Door_Closed.Input(false);
			InterfaceToWriteKind := User;
			Washing_State := Starting;
         end if;
         Next := Next + Period;
      end loop;
   end ModelTask;

   --------------------------------------------------------------------
   --NET SECTION

   task body BarrelReceiver is
      Next : Ada.Real_Time.Time;
      Period   : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(1200);
      Address  : Sock_Addr_Type;
      Socket   : Socket_Type;
      Channel  : Stream_Access;
      Data : Float := 0.0;
      Previous_Barrel_Command : Barrel_Commands := Off;
   begin
      Next := Ada.Real_Time.Clock;
      Address.Addr := Addresses (Get_Host_By_Name (Host_Name), 1);
      Address.Port := 5001;
      Create_Socket (Socket);
      Set_Socket_Option (Socket, Socket_Level, (Reuse_Address, True));
      Connect_Socket (Socket, Address);
      Channel := Stream (Socket);
      loop
         delay until Next;
         if Barrel_Command /= Previous_Barrel_Command then
            String'Output (Channel, "R:" & Barrel_Command'Img);
            Previous_Barrel_Command := Barrel_Command;
            if String'Input(Channel) /= "OK" then
               Put_Line("Barrel error!");
            end if;
         end if;

         String'Output (Channel, "GET");
         Data := Float'Input (Channel);
         Barrel_Rotation_State.Input(Data);
         if String'Input(Channel) = "LEFT" then
            Barrel_Rotation_State.Input(Left);
         else
            Barrel_Rotation_State.Input(Right);
         end if;

         Next := Next + Period;
      end loop;
   exception
      when E:others =>
         Put_Line("Error: Zadanie Obiekt");
         Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
   end BarrelReceiver;

   task body HeaterReceiver is
      Next : Ada.Real_Time.Time;
      Period   : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(1200);
      Address  : Sock_Addr_Type;
      Socket   : Socket_Type;
      Channel  : Stream_Access;
      Data     : Float := 0.0;
      Previous_Water_Level : Range_Proc_Temp := 0.0;
      Previous_Heater_Command : Heater_Commands := Off;
   begin
      Next := Ada.Real_Time.Clock;
      Address.Addr := Addresses (Get_Host_By_Name (Host_Name), 1);
      Address.Port := 5002;
      Create_Socket (Socket);
      Set_Socket_Option (Socket, Socket_Level, (Reuse_Address, True));
      Connect_Socket (Socket, Address);
      Channel := Stream (Socket);
      loop
         delay until Next;
         if Heater_Command /= Previous_Heater_Command then
            String'Output (Channel, "R:" & Heater_Command'Img);
            Previous_Heater_Command := Heater_Command;
            if String'Input(Channel) /= "OK" then
               Put_Line("Heater error!");
            end if;
         end if;

         String'Output (Channel, "GET");
         Data := Float'Input (Channel);
         Barrel_Water_Temp.Input(Data);

         if Barrel_Water_Level.Output = 0.0 and Previous_Water_Level /= 0.0 then
            String'Output (Channel, "R:RESET");
            if String'Input (Channel) /= "OK" then
               Put_Line("Blad resetu temperatury!");
            else
              Previous_Water_Level := 0.0;
            end if;
         else
            Previous_Water_Level := Barrel_Water_Level.Output;
         end if;

         Next := Next + Period;
      end loop;
   exception
      when E:others =>
         Put_Line("Error: Zadanie Obiekt");
         Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
   end HeaterReceiver;

   task body PumpReceiver is
      Next : Ada.Real_Time.Time;
      Period   : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(1200);
      Address  : Sock_Addr_Type;
      Socket   : Socket_Type;
      Channel  : Stream_Access;
      Data     : Float := 0.0;
      Previous_Pump_In_Command : Pump_Commands := Close;
      Previous_Pump_Out_Command : Pump_Commands := Close;
      Previous_Door_Close_Status : Boolean := false;
	  Message : Ada.Strings.Unbounded.Unbounded_String;
   begin
      Next := Ada.Real_Time.Clock;
      Address.Addr := Addresses (Get_Host_By_Name (Host_Name), 1);
      Address.Port := 5003;
      Create_Socket (Socket);
      Set_Socket_Option (Socket, Socket_Level, (Reuse_Address, True));
      Connect_Socket (Socket, Address);
      Channel := Stream (Socket);
      loop
         delay until Next;
         if Pump_In_Command /= Previous_Pump_In_Command then
            if Pump_In_Command = Open then
               String'Output (Channel, "R:In:" & Pump_In_Command'Img & ":" & Pump_In_Water_Migration'Img);
            else
               String'Output (Channel, "R:In:" & Pump_In_Command'Img);
            end if;
            Previous_Pump_In_Command := Pump_In_Command;
			Message := To_Unbounded_String(String'Input(Channel));
            if To_String(Message) /= "OK" then
               Put_Line("Pump In error!" & To_String(Message));
            end if;
         end if;

         if Pump_Out_Command /= Previous_Pump_Out_Command then
            String'Output (Channel, "R:Out:" & Pump_Out_Command'Img);
            Previous_Pump_Out_Command := Pump_Out_Command;
            if String'Input(Channel) /= "OK" then
               Put_Line("Pump Out error!");
            end if;
         end if;

         if Door_Closed.Output = true and Previous_Door_Close_Status = false then
            String'Output (Channel, "SET:POWDER");
            Float'Output( Channel, Powder_Level.Output);
            if String'Input (Channel) /= "OK" then
               Put_Line("Blad ustawienia proszku!");
            end if;
			
			String'Output (Channel, "SET:LIQUID");
            Float'Output( Channel, Wash_Liquid_Level.Output);
            if String'Input (Channel) /= "OK" then
               Put_Line("Blad ustawienia plynu!");
            end if;
			
			Previous_Door_Close_Status := true;
         end if;
		 
		 if Door_Closed.Output = false then
			Previous_Door_Close_Status := false;
			end if;

         if Pump_In_Water_Migration = Powder then
            String'Output (Channel, "GET:POWDER");
            Data := Float'Input (Channel);
            Powder_Level.Input(Data);
         end if;

         if Pump_In_Water_Migration = Liquid then
            String'Output (Channel, "GET:LIQUID");
            Data := Float'Input (Channel);
            Wash_Liquid_Level.Input(Data);
         end if;

         String'Output (Channel, "GET");
         Data := Float'Input (Channel);
         Barrel_Water_Level.Input(Data);

         Next := Next + Period;
      end loop;
   exception
      when E:others =>
         Put_Line("Error: Zadanie Obiekt");
         Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
   end PumpReceiver;



   ------------------------------------------------------------------------------
   --SHARED VALUES

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

   protected body Shared_True_False  is
      function Output return Boolean is (Data);
      function Image return String is 
	  begin
		if Data = false then
			return "X";
		else
			return "O";
			end if;
	  end Image;
      procedure Input(D: in Boolean) is
      begin
         Data := D;
      end Input;
      procedure Output(D: out Boolean) is
      begin
         D := Data;
      end Output;
   end Shared_True_False;

   protected body Shared_Rotation  is
      function ImageDirection return String is (Dire'Img);
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
   end Shared_Rotation;

begin
   Door_Closed.Input(false);
   Door_Blocked.Input(false);
end WashingMachine;
