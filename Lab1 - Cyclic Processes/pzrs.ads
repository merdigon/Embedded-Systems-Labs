with System;

package Pzrs is
   protected Ekran is
      procedure Pisz(S:String);
      pragma Priority(System.Default_Priority+5);
   end Ekran;

   task GeneratorZdarzen is
      pragma Priority(System.Default_Priority+3);
   end GeneratorZdarzen;

   task ZadanieSporadyczne1 is
      pragma Priority(System.Default_Priority+2);
   end ZadanieSporadyczne1;

   task ZadanieSporadyczne2 is
      pragma Priority(System.Default_Priority+1);
   end ZadanieSporadyczne2;
end Pzrs;
