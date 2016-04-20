-- pzdziel.adb

--pragma Profile(Ravenscar);
with Ada.Numerics.Float_Random;
use Ada.Numerics.Float_Random;
with Ada.Exceptions;
use Ada.Exceptions;

package body Pzdziel is
  
  protected body Zasob  is
    procedure Wstaw(D: in Punkt) is
    begin
      Dan := D;
    end Wstaw;    
    procedure Pobierz(D: out Punkt) is
    begin
      D := Dan;
    end Pobierz;    
    function Pobierz return Punkt is (Dan);
  end Zasob;  

  protected body Ekran is
    procedure Pisz(S : String) is
    begin
      Put_Line(S);
    end Pisz;
  end Ekran;

  task body Prod1 is
    Nastepny : Ada.Real_Time.Time;
    Okres : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(1200);
    Przesuniecie : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(10);
    Gen : Generator;
    Dane: Float := 0.0;
  begin
    Reset(Gen);
    Nastepny := Ada.Real_Time.Clock + Przesuniecie;
    loop
      delay until Nastepny;
      Dane := 100.0*Random(Gen);
      Ekran.Pisz("Producent 1: generuje dane = " & Dane'Img);
      Dana := Dane;
      Nastepny := Nastepny + Okres;
    end loop;
    exception
      when E:others =>
        Put_Line("Error: Zadanie Prod");
        Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
  end Prod1;

  task body Prod2 is
    Nastepny : Ada.Real_Time.Time;
    Okres : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(700);
    Przesuniecie : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(30);
    Gen : Generator;
    Pun : Punkt := (0.0,0.0);
  begin
    Reset(Gen);
    Nastepny := Ada.Real_Time.Clock + Przesuniecie;
    loop
      delay until Nastepny;
      Pun := ( Random(Gen), Random(Gen) );
      Ekran.Pisz("Producent 2: generuje nowy punkt = (" & Pun.X'Img & ", " & Pun.Y'Img & ")");
      Zasob.Wstaw(D => Pun);
      Nastepny := Nastepny + Okres;
    end loop;
    exception
      when E:others =>
        Put_Line("Error: Zadanie Prod");
        Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
  end Prod2;

  task body Kons is
    Nastepny : Ada.Real_Time.Time;
    Okres : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(800);
    Przesuniecie : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(50);
    Dane: Float := 0.0;
    Pun : Punkt := (0.0,0.0);
  begin
    Nastepny := Clock + Przesuniecie;
    loop
      delay until Nastepny;
      Dane := Dana;
      Pun := Zasob.Pobierz;
      Ekran.Pisz("Konsument: dana = " & Dane'Img & ", punkt = (" & Pun.X'Img & ", " & Pun.Y'Img & ")");
      Nastepny := Nastepny + Okres;
    end loop;
    exception
      when E:others =>
        Put_Line("Error: Zadanie Kons");
        Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
  end Kons;

end Pzdziel;
