pragma Profile(Ravenscar);
with System;
with CommonData; use CommonData;

package Heater is
 
   Heater_Command : Heater_Commands       := Off with Atomic;
   
   protected type Shared_Proc_Temp (Pri : System.Priority) 
     with Priority => Pri is
      procedure Input(D: in Range_Proc_Temp);
      procedure Output(D: out Range_Proc_Temp);
      function Output return Range_Proc_Temp;
      function Image return String;
   private
      Data : Range_Proc_Temp := 0.0;
   end Shared_Proc_Temp;
   
   Barrel_Water_Temp     : Shared_Proc_Temp(System.Default_Priority+11);   
   
  
end Heater;
