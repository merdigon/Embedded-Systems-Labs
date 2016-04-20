with Ada.Synchronous_Task_Control;
use Ada.Synchronous_Task_Control;
with Ada.Exceptions;
use Ada.Exceptions;
with Ada.Numerics.Discrete_Random;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Real_Time;
use Ada.Real_Time;
package body Pzrs is

   protected body Ekran is
      procedure Pisz(S:String) is
      begin
         Put_Line(S);
      end Pisz;
   end;

   subtype To is Integer range 100..3000;
   package Losuj is new Ada.Numerics.Discrete_Random(To);
   Sem_Bin: Suspension_Object;

   protected Zdarzenie is
      entry Czekaj(Ok: out Natural);
      procedure Wstaw(Ok: in Natural);
   private
      pragma Priority(System.Default_Priority+4);
      Okres: Natural := 0;
      Jest_Zdarzenie: Boolean := False;
   end Zdarzenie;


   protected body Zdarzenie is
      entry Czekaj(Ok: out Natural) when Jest_Zdarzenie is
      begin
         Jest_Zdarzenie:=False;
         Ok := Okres;
      end Czekaj;

      procedure Wstaw(Ok: in Natural) is
      begin
         Jest_Zdarzenie := True;
         Okres := Ok;
      end Wstaw;

   end Zdarzenie;

   task body GeneratorZdarzen is
      use Losuj;
      Nastepny: Ada.Real_Time.Time;
      Okres: Natural := 1200;
      Przesuniecie: constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(10);
      G: Generator;
   begin
         Reset(G);
         Nastepny := Ada.Real_Time.Clock + Przesuniecie;
         loop
            delay until Nastepny;
            Ekran.Pisz("Zadanie gen zdarzen");
            Set_True(Sem_Bin);
            Okres := Random(G);
            Zdarzenie.Wstaw(Okres);
            Nastepny := Nastepny + Ada.Real_Time.Milliseconds(Okres);
         end loop;
      end GeneratorZdarzen;

   task body ZadanieSporadyczne1 is
   begin
      loop
         Suspend_Until_True(Sem_Bin);
         Set_False(Sem_Bin);
         Ekran.Pisz("Zadanie sporadyczne 1");
      end loop;

   end ZadanieSporadyczne1;

   task body ZadanieSporadyczne2 is
      Ok : Natural := 0;
   begin
      loop
         Zdarzenie.Czekaj(Ok);
         Ekran.Pisz("Zadanie 2 Dana=" & Ok'Img & " ms");
      end loop;
   end ZadanieSporadyczne2;

begin
   Set_False(Sem_Bin);
end Pzrs;
