-- pzdziel.ads

with System;

with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Real_Time;
use Ada.Real_Time;

with Conf;

package Pzdziel is

  Dana: Float := 0.0 with Atomic;
  
  type Punkt is record
    X, Y : Float := 0.0;
  end record;
  
  protected Zasob with Priority => (System.Default_Priority+4) is
    procedure Wstaw(D: in Punkt);
    procedure Pobierz(D: out Punkt);
    function Pobierz return Punkt;
  private
    Dan : Punkt := (0.0, 0.0);  
  end Zasob;  

  protected Ekran with Priority => (System.Default_Priority+3) is
    procedure Pisz(S : String);
  end Ekran;

  task Prod1 with Priority => (System.Default_Priority+2);
  
  task Prod2 with Priority => (System.Default_Priority+2);
  
  task Kons is
    pragma Priority (System.Default_Priority+1);
  end Kons;

end Pzdziel;
