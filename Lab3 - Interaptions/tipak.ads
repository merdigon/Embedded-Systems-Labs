-- tipak.ads
-- materiały dydaktyczne
-- Jacek Piwowarczyk

pragma Profile (Ravenscar);
with Ada.Synchronous_Task_Control, Ada.Interrupts, Ada.Interrupts.Names;
use Ada.Synchronous_Task_Control, Ada.Interrupts, Ada.Interrupts.Names;

package TIPak is

Sem_Bin: Suspension_Object;
Sem_Bin2: Suspension_Object;

protected Obsluga is

procedure Obsluga_Przerwania;
pragma Attach_Handler(Obsluga_Przerwania, SIGUSR1);

end  Obsluga;

protected Obsluga2 is

procedure Obsluga_Przerwania2;
pragma Attach_Handler(Obsluga_Przerwania2, SIGUSR2);

end  Obsluga2;

task ZadInt; 

task ZadInt2; 

end TIPak;
