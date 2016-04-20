pragma Profile(Ravenscar);

with System, Bufor, Ada.Text_IO, Ada.Real_Time;
use Bufor, Ada.Text_IO, System, Ada.Real_Time;

package body Zadanie is	
	
	task body Producent is
	Nastepny: Ada.Real_Time.Time;
    Przesuniecie: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(1000);
	begin
	loop
		Bufor.Zapisz(1.6);
		Put_Line("Wyprodukowalem: 1.6");
		Nastepny := Ada.Real_Time.Clock + Przesuniecie;
		delay until Nastepny;
	end loop;
	end Producent;

	task body Konsument is
		wartosc : Float;
	begin
	loop
		Bufor.Pobierz(wartosc);
		Put_Line("Pobralem: " & wartosc'Img);
	end loop;
	end Konsument;	
begin
	Put_Line("Start");
	loop
		null;
		end loop;
end Zadanie;
