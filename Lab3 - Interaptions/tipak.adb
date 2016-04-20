-- tipak.adb
-- materiały dydaktyczne
-- Jacek Piwowarczyk

with Ada.Text_IO;
use Ada.Text_IO;

package body TIPak is

protected body Obsluga is

procedure Obsluga_Przerwania is
begin
  Set_True(Sem_Bin);
end Obsluga_Przerwania;
end Obsluga;

protected body Obsluga2 is

procedure Obsluga_Przerwania2 is
begin
  Set_True(Sem_Bin2);
end Obsluga_Przerwania2;
end Obsluga2;

task body ZadInt is
begin
Put_Line("Początek");
loop
  Suspend_Until_True(Sem_Bin);
  Set_False(Sem_Bin);
  Put_Line("Przerwanie !!!!"); 
end loop; 
exception 
 when others=> Put_Line("Blad zadania!"); 
end ZadInt;

task body ZadInt2 is
begin
Put_Line("Początek2");
loop
  Suspend_Until_True(Sem_Bin2);
  Set_False(Sem_Bin2);
  Put_Line("Przerwanie2 !!!!"); 
end loop; 
exception 
 when others=> Put_Line("Blad zadania2!"); 
end ZadInt2;

begin
 Set_False(Sem_Bin);
 Set_False(Sem_Bin2);
end TIPak;
