
   protected body Shared_Proc_Temp  is
      procedure Input(D: in Range_Proc_Temp) is
      begin
         Data := D;
      end Input;
      procedure Output(D: out Range_Proc_Temp) is
      begin
         D := Data;
      end Output;
      function Output return Range_Proc_Temp is (Data);
      function Image return String is
         Str : String(1..6);
      begin
         Put(To=>Str, Item=>Data,Aft=>2, Exp=>0);
         return Str;
      end Image;
   end Shared_Proc_Temp;

   protected body Shared_True_False  is
      procedure Input(D: in Boolean) is
      begin
         Data := D;
      end Input;
      procedure Output(D: out Boolean) is
      begin
         D := Data;
      end Output;
      function Output return Boolean is (Data);
      function Image return String is (Data'Img);
   end Shared_True_False;

   protected body Shared_Rotation  is
      procedure Input(S: in Float; D: in Direction) is
      begin
         Speed := S;
         Dire := D;
      end Input;
      procedure Input(D: in Direction) is
      begin
         Dire := D;
      end Input;
      procedure Input(S: in Float) is
      begin
         Speed := S;
      end Input;
      procedure Output(S: out Float; D: out Direction) is
      begin
         S := Speed;
         D := Dire;
      end Output;
      procedure Output(S: out Float) is
      begin
         S := Speed;
      end Output;
      procedure Output(D: out Direction) is
      begin
         D := Dire;
      end Output;
      function OutputSpeed return Float is (Speed);
      function OutputDirection return Direction is (Dire);
      function ImageSpeed return String is
         Str : String(1..6);
      begin
         Put(To=>Str, Item=>Speed,Aft=>2, Exp=>0);
         return Str;
      end ImageSpeed;
      function ImageDirection return String is (Dire'Img);
   end Shared_Rotation;


protected type Shared_Proc_Temp (Pri : System.Priority)
     with Priority => Pri is
      procedure Input(D: in Range_Proc_Temp);
      procedure Output(D: out Range_Proc_Temp);
      function Output return Range_Proc_Temp;
      function Image return String;
   private
      Data : Range_Proc_Temp := 0.0;
   end Shared_Proc_Temp;


   protected type Shared_True_False(Pri : System.Priority)
     with Priority => Pri is
      procedure Input(D: in Boolean);
      procedure Output(D: out Boolean);
      function Output return Boolean;
      function Image return String;
   private
      Data : Boolean := false;
   end Shared_True_False;

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
