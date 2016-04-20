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

with Ada.Strings;
use Ada.Strings;
with Ada.Strings.Fixed;
use Ada.Strings.Fixed;

with Ada.Exceptions;
use Ada.Exceptions;

package body Model is
  
  subtype Zakres_Temp_Wew is Float range 5.0..40.0;
  subtype Zakres_Temp_Zew is Float range -40.0..50.0;
   
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
  
  protected body Ekran is
    -- implementacja dla Linuxa i OSX
    procedure Pisz_XY(X,Y: Positive; S: String; Atryb : Atrybuty := Czysty) is
      Przed : String := ASCII.ESC & "[" &
        (case Atryb is 
           when Jasny => "1m", when Podkreslony => "4m", when Negatyw => "7m",
           when Migajacy => "5m", when Szary => "2m", when Czysty => "0m");          
    begin
      Put(Przed);
      Put(ASCII.ESC & "[" & Trim(Y'Img,Both) & ";" & Trim(X'Img,Both) & "H" & S);
      Put(ASCII.ESC & "[0m");
    end Pisz_XY;  
    procedure Czysc is
    begin
      Put(ASCII.ESC & "[2J");
    end Czysc;    
  end Ekran;

  task Sterownik 
    with Priority => (System.Default_Priority+4);

  task Obiekt
    with Priority => (System.Default_Priority+3);
    
  task Otoczenie
    with Priority => (System.Default_Priority+1);  
    
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

  task body Otoczenie is 
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
  end Otoczenie;  
  
  task Wypisanie
    with Priority => (System.Default_Priority+2);  
   
  task body Wypisanie is 
    Nastepny : Ada.Real_Time.Time;
    Okres    : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(400);
    Przesuniecie : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(50);
    Temp_Zew, 
    Temp_Akt, 
    Temp_Zad : Float := 0.0;
  begin
    Nastepny := Ada.Real_Time.Clock + Przesuniecie;
    loop
      delay until Nastepny;
      Ekran.Czysc;      
      Ekran.Pisz_XY(1,1,"+----------- Symulacja regulatora temperatury ----------+", Jasny);
      Ekran.Pisz_XY(1,11,"+-------------------------------------------------------+", Jasny);
      for W in 2..10 loop
        Ekran.Pisz_XY(1, W ,"|", Jasny);
        Ekran.Pisz_XY(57, W ,"|", Jasny);
      end loop;  
      Ekran.Pisz_XY(4,3, "Regulator", Podkreslony);
      Ekran.Pisz_XY(23,3, "Obiekt", Podkreslony);
      Ekran.Pisz_XY(43,3, "Otoczenie", Podkreslony);
      Ekran.Pisz_XY(20, 5, "Temp. aktualna");
      Ekran.Pisz_XY(23,6, Temp_Aktualna.Obraz & " C ", Negatyw);
      Ekran.Pisz_XY(3, 5, "Temp. zadana");
      Ekran.Pisz_XY(4,6, Temp_Zadana.Obraz & " C ", Negatyw);
      Ekran.Pisz_XY(40, 5, "Temp. zewnetrzna");
      Ekran.Pisz_XY(44,6, Temp_Zewnetrzna.Obraz & " C ", Negatyw);
      Ekran.Pisz_XY(4,8, "Sterowanie");
      Ekran.Pisz_XY(4,9, Stan_Ster'Img, Negatyw);
      Ekran.Pisz_XY(3, 11, " Ctl-C .. Koniec; T. zadana -> D - w dół, G - w góre " & ASCII.ESC);
      Nastepny := Nastepny + Okres;
    end loop;
  exception
      when E:others =>
        Put_Line("Error: Zadanie Interfejs_U");
        Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
  end Wypisanie; 
  
  protected  Klawisz 
      with Priority => (System.Default_Priority+7) is
    procedure Podaj(Zn : out Character);
  end Klawisz; 
  
  protected body Klawisz is
    procedure Podaj(Zn : out Character) is
    begin
      Get_Immediate(Zn);
    end Podaj;
  end Klawisz;   
  
  type Stan_Klawisza is (W_Gore, W_Dol);
  
  protected Klawisz_Temp_Zew 
      with Priority => (System.Default_Priority+7) is
    entry Czekaj(SK : out Stan_Klawisza);
    procedure Wstaw(SK : in Stan_Klawisza);
  private   
    SKL : Stan_Klawisza;
    Jest_Nowy : Boolean := False;
  end Klawisz_Temp_Zew;
  
  protected body Klawisz_Temp_Zew is
    entry Czekaj(SK : out Stan_Klawisza) when Jest_Nowy is
    begin
      Jest_Nowy := False;
      SK := SKL;
    end Czekaj;  
    procedure Wstaw(SK : in Stan_Klawisza) is
    begin
      Jest_Nowy := True;
      SKL := SK;
    end Wstaw;  
  end Klawisz_Temp_Zew;
  
  task Klawiatura 
    with Priority => (System.Default_Priority+5); 
  
  task body Klawiatura is
    Zn   : Character;
  begin
    loop
      Klawisz.Podaj(Zn);
      Ekran.Pisz_XY(45,8,"Klawisz");
      Ekran.Pisz_XY(47,9, " " & Zn & " ", Negatyw);
      if Zn in 'g'|'G'|'A' then
        Klawisz_Temp_Zew.Wstaw(W_Gore);  
      elsif Zn in 'd'|'D'|'B' then
        Klawisz_Temp_Zew.Wstaw(W_Dol);  
      end if;  
    end loop;  
  end Klawiatura;  
  
  task Ustaw_Temp_Zew 
    with Priority => (System.Default_Priority+6); 
  
  task body Ustaw_Temp_Zew is
    Temp : Float := 0.0;
    SKL  : Stan_Klawisza;
  begin
    loop
      Klawisz_Temp_Zew.Czekaj(SKL);
      case SKL is
        when W_Gore => 
          Temp := Temp_Zadana.Pobierz + 1.0;
          if Temp in Zakres_Temp_Wew then 
            Temp_Zadana.Wstaw( Temp );
          end if;
        when W_Dol =>
          Temp := Temp_Zadana.Pobierz - 1.0;
          if Temp in Zakres_Temp_Wew then 
            Temp_Zadana.Wstaw( Temp );
          end if; 
      end case;    
    end loop;
  end Ustaw_Temp_Zew;
  
begin
  -- inicjowanie
  Ekran.Czysc;   
  Temp_Zewnetrzna.Wstaw( -20.0 );
  Temp_Zadana.Wstaw( 18.0 );
  Temp_Aktualna.Wstaw( 21.0 );
end Model;

