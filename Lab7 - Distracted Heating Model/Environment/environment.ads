pragma Profile(Ravenscar);
with System;

package Environment is

	  protected type Dzielona(Pri : System.Priority) 
	      with Priority => Pri is
	    procedure Wstaw(D: in Float);
	    procedure Pobierz(D: out Float);
	    function Pobierz return Float;
	    function Obraz return String;
	  private
	    Dan : Float := 0.0;
	  end Dzielona;

	type Pory_Roku is (Wiosna, Lato, Jesien, Zima);

	subtype Zakres_Temp_Zew is Float range -40.0..50.0;

	Pora_Roku : Pory_Roku        := Zima with Atomic;

	Temp_Zewnetrzna : Dzielona(System.Default_Priority+12);

end Environment;
