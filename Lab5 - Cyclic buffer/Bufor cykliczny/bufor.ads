pragma Profile(Ravenscar);

with System, Ada.Synchronous_Task_Control;
use System, Ada.Synchronous_Task_Control;

package Bufor is

	procedure Place_Item(Item : Float); 
	procedure Extract_Item(Item : out Float); 

end Bufor;
