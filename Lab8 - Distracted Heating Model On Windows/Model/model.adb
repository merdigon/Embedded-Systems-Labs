-- model.adb
-- materiały dydaktyczne
-- 2016
-- Jacek Piwowarczyk
--
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

package body Model is
   
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
  
  task Sterownik 
    with Priority => (System.Default_Priority+4);

  task Obiekt
    with Priority => (System.Default_Priority+3);    

  task EnviromentReceiver 
    with Priority => (System.Default_Priority+5); 
    
  task body Sterownik is 
    Nastepny : Ada.Real_Time.Time;
    Okres : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(800);
    Przesuniecie : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(10);
    Temp_Zew, 
    Temp_Akt, 
    Temp_Zad : Float := 0.0;
  begin
    Nastepny := Ada.Real_Time.Clock + Przesuniecie;
    loop
      delay until Nastepny;
      Temp_Akt := Temp_Aktualna.Pobierz;
      Temp_Zad := Temp_Zadana.Pobierz;
      -- dodac histereze!
      if Temp_Zad - Temp_Akt > 0.2 then
        Stan_Ster := Grzanie;
      elsif Temp_Zad - Temp_Akt < -0.2 then
        Stan_Ster := Chlodzenie;
      else  
        Stan_Ster := Wylacz;
      end if;  
      Nastepny := Nastepny + Okres;
    end loop;
  exception
    when E:others =>
      Put_Line("Error: Zadanie Sterownik");
      Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
  end Sterownik;     
  
  task body Obiekt is 
    use Ada.Numerics.Float_Random;
    Nastepny : Ada.Real_Time.Time;
    Okres : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(500);
    Przesuniecie : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(10);
    Gen : Generator;
    Temp_Zew, 
    Temp_Akt, 
    Temp : Float := 0.0;
    
    function Znak(Arg1, Arg2: Float) return Float is 
       (if Arg1 > Arg2 then 1.0 elsif Arg1 <Arg2 then -1.0 else 0.0 ); 
  begin
    Reset(Gen);
    Nastepny := Ada.Real_Time.Clock + Przesuniecie;
    loop
      delay until Nastepny;
      Temp_Akt := Temp_Aktualna.Pobierz;
      pragma Assert( Temp_Akt in Zakres_Temp_Wew );
      Temp_Zew := Temp_Zewnetrzna.Pobierz; 
      pragma Assert( Temp_Zew in Zakres_Temp_Zew );
      Temp := Temp_Akt; 
      if Stan_Ster = Grzanie then
        Temp := Temp + 0.05*Random(Gen); 
      elsif Stan_Ster = Chlodzenie then
        Temp := Temp - 0.05*Random(Gen);   
      else 
        -- wpływ temperatury zewnetrznej na temperature wewn. np. przez okna
        Temp := Temp + 0.005*Random(Gen) * Znak( Temp_Zew, Temp_Akt); 
      end if;   
      Temp_Akt := (if Temp in Zakres_Temp_Wew then Temp else Temp_Akt);
      Temp_Aktualna.Wstaw( Temp_Akt ); 
      Nastepny := Nastepny + Okres;
    end loop;
  exception
     when E:others =>
       Put_Line("Error: Zadanie Obiekt");
       Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
  end Obiekt;   

  task body EnviromentReceiver is
    Nastepny : Ada.Real_Time.Time;
    Okres   : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(1200);
    Address  : Sock_Addr_Type;
    Socket   : Socket_Type;
    Channel  : Stream_Access;
      Dane     : Float := 0.0;
      Group : String := "192.168.0.128";
  begin
    Nastepny := Ada.Real_Time.Clock;
    Address.Addr := Inet_Addr(Group);
    Address.Port := 5021;
    Create_Socket (Socket);
    Set_Socket_Option (Socket, Socket_Level, (Reuse_Address, True));
    Set_Socket_Option (Socket, IP_Protocol_For_IP_Level, (Add_Membership, Inet_Addr (Group), Any_Inet_Addr));
    Connect_Socket (Socket, Address);
    Channel := Stream (Socket);
    loop
      delay until Nastepny;
      String'Output (Channel, "GET");
      Dane := Float'Input (Channel);      
      Temp_Zewnetrzna.Wstaw(Dane);
      Nastepny := Nastepny + Okres;
    end loop;
  exception
     when E:others =>
       Put_Line("Error: Zadanie Obiekt");
       Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
  end EnviromentReceiver;
  
begin
  -- inicjowanie
  Temp_Zadana.Wstaw( 23.0 );
  Temp_Aktualna.Wstaw( 16.5 );
  Temp_Zewnetrzna.Wstaw( 0.0 );
end Model;

