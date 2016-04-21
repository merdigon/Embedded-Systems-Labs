-- model.ads
-- materiały dydaktyczne
-- 2016
-- Jacek Piwowarczyk
--
pragma Profile(Ravenscar);
with System;

package Model is

  type Stany_Sterowania is (Grzanie, Chlodzenie, Wylacz);
  type Stany_Klawisza is (W_Gore, W_Dol);
  
  subtype Zakres_Temp_Wew is Float range 5.0..40.0;
  subtype Zakres_Temp_Zew is Float range -40.0..50.0;
 
  Stan_Ster : Stany_Sterowania := Wylacz with Atomic;
  
  protected type Dzielona(Pri : System.Priority) 
      with Priority => Pri is
    procedure Wstaw(D: in Float);
    procedure Pobierz(D: out Float);
    function Pobierz return Float;
    function Obraz return String;
  private
    Dan : Float := 0.0;
  end Dzielona;
  
  Temp_Zadana     : Dzielona(System.Default_Priority+10);
  Temp_Aktualna   : Dzielona(System.Default_Priority+11);
  Temp_Zewnetrzna : Dzielona(System.Default_Priority+12);
  
end Model;

