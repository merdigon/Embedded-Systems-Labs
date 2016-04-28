pragma Profile(Ravenscar);
with System;
with Environment; pragma Unreferenced(Environment);

procedure Main_env 
  with Priority => System.Priority'First is
begin
  loop
    null;
  end loop;
end Main_env ;
