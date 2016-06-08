pragma Profile(Ravenscar);
with System;
with CommonData;
use CommonData;
with Ada.Real_Time;
use Ada.Real_Time;


package WashingMachine is
   
   type Washing_States is (Starting, FirstSlowSpin, SecondSlowSpin, Spin, ThirdSlowSpin, Ending);
   type InterfaceToWrite is (User, Extended);
   type WashingType is (ECO, Normal, Extended);
 
   Barrel_Command : Barrel_Commands        := Off with Atomic;
   Pump_In_Command : Pump_Commands        := Close with Atomic;
   Pump_Out_Command : Pump_Commands      := Close with Atomic;
   Heater_Command : Heater_Commands       := Off with Atomic;
   Pump_In_Water_Migration : Water_Migration_Via := Normal with Atomic;
   Washing_State : Washing_States := Starting with Atomic;
   InterfaceToWriteKind : InterfaceToWrite := User with Atomic;
   Choosen_Washing_Type : WashingType := Normal with Atomic;
   SimulationTime : Integer := 0;
   
   protected type Shared_True_False(Pri : System.Priority)
     with Priority => Pri is
      procedure Input(D: in Boolean);
      procedure Output(D: out Boolean);
      function Output return Boolean;
      function Image return String;
   private
      Data : Boolean := false;
   end Shared_True_False;
   
   protected type Shared_Proc_Temp (Pri : System.Priority)
     with Priority => Pri is
      procedure Input(D: in Range_Proc_Temp);
      procedure Output(D: out Range_Proc_Temp);
      function Output return Range_Proc_Temp;
      function Image return String;
   private
      Data : Range_Proc_Temp := 0.0;
   end Shared_Proc_Temp;
   
   protected type Shared_Rotation(Pri : System.Priority)
     with Priority => Pri is
      procedure Input(S: in Float; D: in Direction);
      procedure Input(D: in Direction);
      procedure Input(S: in Float);
      procedure Output(S: out Float; D: out Direction);
      procedure Output(D: out Direction);
      procedure Output(S: out Float);
      function OutputSpeed return Float;
      function OutputDirection return Direction;
      function ImageSpeed return String;
      function ImageDirection return String;
   private
      Speed : Float := 0.0;
      Dire : Direction := Left;
   end Shared_Rotation;
    
   Barrel_Water_Temp     : Shared_Proc_Temp(System.Default_Priority+11);
   Barrel_Water_Level     : Shared_Proc_Temp(System.Default_Priority+12);
   Powder_Level     : Shared_Proc_Temp(System.Default_Priority+13);
   Wash_Liquid_Level     : Shared_Proc_Temp(System.Default_Priority+14);
   Door_Closed     : Shared_True_False(System.Default_Priority+15);   
   Door_Blocked     : Shared_True_False(System.Default_Priority+10);   
   Barrel_Rotation_State   : Shared_Rotation(System.Default_Priority+9); 
  
end WashingMachine;
