-- przegladarka_www.adb

with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Real_Time;
use Ada.Real_Time;
with Ada.Float_Text_IO;
use Ada.Float_Text_IO;
with Ada.Exceptions;
use Ada.Exceptions;
with Model;
use Model;
with WebR_IO;
use WebR_IO;

package body Przegladarka_WWW is

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
      Czysc;
      Pisz("<h3> Symulacja regulatora temperatury </h3>");
      PiszNL("<b>Regulator</b>");
      PiszNL("Temp. zadana = <b>"&Temp_Zadana.Obraz & " C</b>");
      PiszNL("Sterowanie : <b>"&Stan_Ster'Img & "</b>");
      PiszNL("<b>Obiekt</b>");
      PiszNL("Temp. aktualna = <b>"&Temp_Aktualna.Obraz & " C</b>");
      PiszNL("<b>Otoczenie</b>");
      PiszNL("Temp. zewnetrzna = <b>"&Temp_Zewnetrzna.Obraz & " C</b>");
      PiszNL("Pora roku : <b>"&Pora_Roku'Img&"</b>");

      Nastepny := Nastepny + Okres;
    end loop;
  exception
      when E:others =>
        Put_Line("Error: Zadanie Interfejs_U");
        Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
  end Wypisanie;

end Przegladarka_WWW;
