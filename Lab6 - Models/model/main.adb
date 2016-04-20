-- main.adb
-- materiały dydaktyczne
-- 2016
-- Jacek Piwowarczyk
--
-- UWAGA!!
-- oprogramoanie zgodne z systemami:
-- Linux i Mac OSX
-- pod Windows ??? ... raczej nie

pragma Profile(Ravenscar);
with System;
with Model; pragma Unreferenced(Model);

procedure Main 
  with Priority => System.Priority'First is
begin
  loop
    null;
  end loop;
end Main;
