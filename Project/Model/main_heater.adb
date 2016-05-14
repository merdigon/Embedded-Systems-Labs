pragma Profile(Ravenscar);
with System;
with Heater; pragma Unreferenced(Heater);

procedure Main_heater 
  with Priority => System.Priority'First is
begin
  loop
    null;
  end loop;
end Main_heater ;
