pragma Profile(Ravenscar);
with System;
with Barrel; pragma Unreferenced(Barrel);

procedure Main_barrel 
  with Priority => System.Priority'First is
begin
  loop
    null;
  end loop;
end Main_barrel ;
