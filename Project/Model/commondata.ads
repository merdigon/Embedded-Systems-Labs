pragma Profile(Ravenscar);
with System;

package CommonData is

   type Barrel_Commands is (SlowTwoWay, Spin, Off);
   type Pump_Commands is (Open, Close);
   type Water_Migration_Via is (Normal, Powder, Liquid);
   type Heater_Commands is (Heat, Off);
   type Direction is (Left, Right);

   subtype Range_Proc_Temp is Float range 0.0..100.0;

end CommonData;
