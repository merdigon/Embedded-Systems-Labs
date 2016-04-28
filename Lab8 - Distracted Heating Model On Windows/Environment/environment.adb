with System;

with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Real_Time;
use Ada.Real_Time;
with Ada.Float_Text_IO;
use Ada.Float_Text_IO;
with Ada.Numerics.Float_Random;
with Ada.Exceptions;
use Ada.Exceptions;
with GNAT.Sockets; use GNAT.Sockets;

package body Environment is

	task EnvironmentTask
	    with Priority => (System.Default_Priority+1); 

	task EnvironmentSocket
	    with Priority => (System.Default_Priority+2);

	task body EnvironmentSocket is
	    Address : Sock_Addr_Type;
	    Socket  : Socket_Type;
    	    Server   : Socket_Type;
	    Channel : Stream_Access;
	    Request : String := "GET";
	begin
    	    Address.Addr := Addresses (Get_Host_By_Name (Host_Name), 1);
            Address.Port := 5021;
            Create_Socket (Server);
            Set_Socket_Option (Server, Socket_Level, (Reuse_Address, True));
            Bind_Socket (Server, Address);
            Listen_Socket (Server);
            Accept_Socket (Server, Socket, Address);    
            Channel := Stream (Socket);	    
	    loop
              Request := String'Input (Channel);
	      --  Send message to kontroler
	      Put_Line("Wysyłam dane ...");
	      Float'Output (Channel, Temp_Zewnetrzna.Pobierz);
	    end loop;
	exception
    	when E:others =>
      		Close_Socket (Socket);
      		Put_Line("Error: Zadanie Sensor");
      		Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
  	end EnvironmentSocket;

	task body EnvironmentTask is 
	    use Ada.Numerics.Float_Random;
	    Nastepny : Ada.Real_Time.Time;
	    Okres : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(3000);
	    Przesuniecie : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(30);
	    Gen  : Generator;
	    Temp : Float := 0.0;
	  begin
	    Reset(Gen);
	    Nastepny := Ada.Real_Time.Clock + Przesuniecie;	    
	    loop
	      delay until Nastepny;
	      Temp := 0.8*Random(Gen) - 0.4 + Temp_Zewnetrzna.Pobierz; 
	      pragma Assert( Temp in Zakres_Temp_Zew );
	      if Temp in Zakres_Temp_Zew then
		Temp_Zewnetrzna.Wstaw( Temp );
	      end if;  
	      Nastepny := Nastepny + Okres;
	    end loop;
	  exception
	     when E:others =>
	       Put_Line("Error: Zadanie Otoczenie");
	       Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
	  end EnvironmentTask;  

	protected body Dzielona  is
	    procedure Wstaw(D: in Float) is
	      begin
		Dan := D;
	      end Wstaw;
	    procedure Pobierz(D: out Float) is
	      begin
		D := Dan;
	      end Pobierz;
	    function Pobierz return Float is (Dan);
	    function Obraz return String is
	      Str : String(1..6);
	    begin
	      Put(To=>Str, Item=>Dan,Aft=>2, Exp=>0);
	      return Str;
	    end Obraz;    
	  end Dzielona;

begin
  -- inicjowanie
  Temp_Zewnetrzna.Wstaw( -20.0 );
  Pora_Roku := Zima;
end Environment;
