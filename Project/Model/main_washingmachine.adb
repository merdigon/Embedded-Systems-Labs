pragma Profile(Ravenscar);
with System;
with Terminal;
use Terminal;
with WashingMachine; pragma Unreferenced(WashingMachine);

procedure Main_washingMachine
  with Priority => System.Priority'First is
begin
  loop
    null;
  end loop;
end Main_washingMachine ;
