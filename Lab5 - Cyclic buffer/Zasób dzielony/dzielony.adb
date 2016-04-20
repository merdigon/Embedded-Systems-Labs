-- dzielony.adb

pragma Profile(Ravenscar);
with System;
with Pzdziel; pragma Unreferenced(Pzdziel);

procedure Dzielony with Priority => System.Priority'First is

--  pragma Priority (System.Priority'First);

begin
  Pzdziel.Ekran.Pisz("Procedura glowana ");
  loop
    null;
  end loop;

end Dzielony;
