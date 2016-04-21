pragma Profile(Ravenscar);
with System;

package washingMachine is

  type Rozkazy_Sterowania_Bebna is (Krec_Lewo, Krec_Prawo, Wylacz);
  
  subtype Zakres_Temp_Wody is Float range 0.0..100.0;
  subtype Predkosc is Float range 0.0..200.0;
 
  Rozkaz_Bebna : Rozkazy_Sterowania_Bebna        := Wylacz with Atomic;
  
  protected type Dzielona_Predkosc(Pri : System.Priority) 
      with Priority => Pri is
    procedure Wstaw(D: in Float);
    procedure Pobierz(D: out Float);
    function Pobierz return Float;
    function Obraz return String;
  private
    Dan : Predkosc := 0.0;
  end Dzielona_Predkosc;

  protected type Dzielona_Temp_Wody(Pri : System.Priority) 
      with Priority => Pri is
    procedure Wstaw(D: in Float);
    procedure Pobierz(D: out Float);
    function Pobierz return Float;
    function Obraz return String;
  private
    Dan : Zakres_Temp_Wody := 0.0;
  end Dzielona_Temp_Wody;
	
  Predkosc_Bebna     : Dzielona_Predkosc(System.Default_Priority+10);
  Temp_Wody_Bebna     : Dzielona_Temp_Wody(System.Default_Priority+10);
  
  
end Model;
