-- TestInt

with Ada.Text_IO, TIPak;
use Ada.Text_IO, TIPak;

procedure TestInt is
begin
  Put_Line("kill -SIGUSR1 <psid>, Ctrl+C Koniec");
end TestInt;

-----------------------------------------  

-- tipak.ads

with Ada.Synchronous_Task_Control, Ada.Interrupts, Ada.Interrupts.Names;
use Ada.Synchronous_Task_Control, Ada.Interrupts, Ada.Interrupts.Names;

package TIPak is

Sem_Bin: Suspension_Object;

protected Obsluga is

procedure Obsluga_Przerwania;
pragma Attach_Handler(Obsluga_Przerwania, SIGUSR1);

end  Obsluga;

task ZadInt ; 

end TIPak;

----------------------------------------
-- tipak.adb

with Ada.Text_IO;
use Ada.Text_IO;

package body TIPak is

protected body Obsluga is

procedure Obsluga_Przerwania is
begin
 Set_True(Sem_Bin);
end Obsluga_Przerwania;
end Obsluga;

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

begin
 Set_False(Sem_Bin);
end TIPak;