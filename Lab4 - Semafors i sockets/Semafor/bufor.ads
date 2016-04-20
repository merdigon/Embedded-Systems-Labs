pragma Profile(Ravenscar);

with System, Ada.Synchronous_Task_Control;
use System, Ada.Synchronous_Task_Control;

package Bufor is

	Sem_We : Suspension_Object; 
	Sem_Wy : Suspension_Object;
	TotalValue : Float;

	procedure Zapisz (value : in Float);

	procedure Pobierz (valueToAss : out Float);

end Bufor;
