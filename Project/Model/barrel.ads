pragma Profile(Ravenscar);
with System;
with CommonData;
use CommonData;

package Barrel is
 
  Barrel_Command : Barrel_Commands       := Off with Atomic;
  
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
  
  Barrel_Rotation     : Shared_Rotation(System.Default_Priority+11);
  
end Barrel;
