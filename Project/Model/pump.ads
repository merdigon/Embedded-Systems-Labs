pragma Profile(Ravenscar);
with System;
with CommonData;
use CommonData;

package Pump is

   Pump_In_Command : Pump_Commands := Close;
   Pump_Out_Command : Pump_Commands := Close;
   Pump_In_Water_Migration : Water_Migration_Via := Normal;

   protected type Shared_Proc_Temp (Pri : System.Priority)
     with Priority => Pri is
      procedure Input(D: in Range_Proc_Temp);
      procedure Output(D: out Range_Proc_Temp);
      function Output return Range_Proc_Temp;
      function Image return String;
   private
      Data : Range_Proc_Temp := 0.0;
   end Shared_Proc_Temp;

   Barrel_Water_Level     : Shared_Proc_Temp(System.Default_Priority+11);
   Powder_Level     : Shared_Proc_Temp(System.Default_Priority+12);
   Washing_Liquid_Level     : Shared_Proc_Temp(System.Default_Priority+13);

end Pump;
