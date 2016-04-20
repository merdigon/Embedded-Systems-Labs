-- main_web.adb
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
with Ada.Text_IO;
use Ada.Text_IO;

with Model; pragma Unreferenced(Model);
with Przegladarka_WWW; pragma Unreferenced(Przegladarka_WWW);

procedure Main_Web
  with Priority => System.Priority'First is
begin
  Put_Line("Main: start");
  loop
    null;
  end loop;
end Main_Web;
