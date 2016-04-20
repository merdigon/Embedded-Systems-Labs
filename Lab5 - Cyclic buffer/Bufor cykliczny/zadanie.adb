pragma Profile(Ravenscar);

with System, Bufor, Ada.Text_IO, Ada.Real_Time;
use Bufor, Ada.Text_IO, System, Ada.Real_Time;

package body Zadanie is	
	Number : Float := 1.2;

	task body Producent is
	Nastepny: Ada.Real_Time.Time;
    	Przesuniecie: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(1000);
	begin
	loop
		Bufor.Place_Item(Number);
		Put_Line("Wyprodukowalem1: " & Number'Img);
		Number := Number + 1.0;
		Nastepny := Ada.Real_Time.Clock + Przesuniecie;
		delay until Nastepny;
	end loop;
	end Producent;

	task body Producent2 is
	Nastepny: Ada.Real_Time.Time;
    	Przesuniecie: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(1000);
	begin
	loop
		Bufor.Place_Item(Number);
		Put_Line("Wyprodukowalem2: " & Number'Img);
		Number := Number + 1.0;
		Nastepny := Ada.Real_Time.Clock + Przesuniecie;
		delay until Nastepny;
	end loop;
	end Producent2;

	task body Konsument is
		Nastepny: Ada.Real_Time.Time;
    		Przesuniecie: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(1000);
		wartosc : Float;
	begin
	loop
		Bufor.Extract_Item(wartosc);
		Put_Line("Pobralem: " & wartosc'Img);
		Nastepny := Ada.Real_Time.Clock + Przesuniecie;
		delay until Nastepny;
	end loop;
	end Konsument;	
begin
	Put_Line("Start");
	loop
		null;
		end loop;
end Zadanie;
