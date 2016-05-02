pragma Profile(Ravenscar);
with System;
with Pump; pragma Unreferenced(Pump);

procedure Main_pump
  with Priority => System.Priority'First is
begin
  loop
    null;
  end loop;
end Main_pump ;
