-- terminal.adb

with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Real_Time;
use Ada.Real_Time;
with Ada.Float_Text_IO;
use Ada.Float_Text_IO;
with Ada.Strings;
use Ada.Strings;
with Ada.Strings.Fixed;
use Ada.Strings.Fixed;
with Ada.Exceptions;
use Ada.Exceptions;
with WashingMachine;
use WashingMachine;
with CommonData;
use CommonData;
with NT_Console;
use NT_Console;

package body Terminal is

  protected body Screen is
    -- implementacja dla Linuxa i OSX
      procedure Write_XY(X,Y: Positive; S: String; Atryb : Atribute := Clean) is
         NColorF : Color_Type;
         NColorB : Color_Type;
         ColorF : Color_Type;
         ColorB : Color_Type;
      begin
         if Atryb = Clean then
            NColorB := Black;
            NColorF := White;
         elsif Atryb = Bright then
            NColorB := Blue;
            NColorF := Brown;
         elsif Atryb = Underlined then
            NColorB := Green;
            NColorF := Red;
         elsif Atryb = Negative then
            NColorB := Light_Red;
            NColorF := Light_Cyan;
         else
            NColorB := Yellow;
            NColorF := Gray;
         end if;

         ColorF := Get_Foreground;
         ColorB := Get_Background;
         Set_Background(NColorB);
         Set_Foreground(NColorF);
         Goto_XY(X,Y);
         Put(S);
         Set_Background(ColorB);
         Set_Foreground(ColorF);
    end Write_XY;
    procedure Clear is
      begin
         Clear_Screen;
    end Clear;
  end Screen;

  task Printing
    with Priority => (System.Default_Priority+2);

  task body Printing is
    Next : Ada.Real_Time.Time;
      Period    : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(400);
      Speed : Float := 0.0;
      Dire : CommonData.Direction := Left;
      Temp : Range_Proc_Temp := 0.0;
      Water_Level : Range_Proc_Temp := 0.0;
      Door_Closed_State : Boolean := false;
      Door_Blocked_State : Boolean := false;
    Shift : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(50);
  begin
    Next := Ada.Real_Time.Clock + Shift;
    loop
         delay until Next;
         --Speed := Barrel_Rotation_State.ImageSpeed;
         --Dire := Barrel_Rotation_State.OutputDirection;
         --Temp := Barrel_Water_Temp.Output;
         --Water_Level := Barrel_Water_Level.Output;
         Door_Closed_State := Door_Closed.Output;
         Door_Blocked_State := Door_Blocked.Output;
      Screen.Clear;
      Screen.Write_XY(1,1,"+----------- Symulacja pralki --------------------------+", Bright);
      for W in 2..24 loop
        Screen.Write_XY(1, W ,"|", Bright);
        Screen.Write_XY(57, W ,"|", Bright);
      end loop;
      Screen.Write_XY(20,2, "Beben", Underlined);
      Screen.Write_XY(2,3,"-------------------------------------------------------", Bright);
      Screen.Write_XY(2,4, "Predkosc", Underlined);
      Screen.Write_XY(22,4, "|", Underlined);
      Screen.Write_XY(25,4, Barrel_Rotation_State.ImageSpeed & " obr/s", Underlined);
      Screen.Write_XY(2,5, "Kierunek", Underlined);
      Screen.Write_XY(22,5, "|", Underlined);
      Screen.Write_XY(25,5, Barrel_Rotation_State.ImageDirection, Underlined);
      Screen.Write_XY(2,6, "Rozkaz", Underlined);
      Screen.Write_XY(22,6, "|", Underlined);
      Screen.Write_XY(25,6, Barrel_Command'Img, Underlined);
      Screen.Write_XY(2,7,"-------------------------------------------------------", Bright);
      Screen.Write_XY(20,8, "Grzalka", Underlined);
      Screen.Write_XY(2,9,"-------------------------------------------------------", Bright);
      Screen.Write_XY(2,10, "Temp. wody", Underlined);
      Screen.Write_XY(22,10, "|", Underlined);
      Screen.Write_XY(25,10, Barrel_Water_Temp.Image & "C", Underlined);
      Screen.Write_XY(2,11, "Rozkaz", Underlined);
      Screen.Write_XY(22,11, "|", Underlined);
      Screen.Write_XY(25,11, Heater_Command'Img, Underlined);
      Screen.Write_XY(2,12,"-------------------------------------------------------", Bright);
      Screen.Write_XY(20,13, "Pompa", Underlined);
      Screen.Write_XY(2,14,"-------------------------------------------------------", Bright);
      Screen.Write_XY(2,15, "Poziom wody", Underlined);
      Screen.Write_XY(22,15, "|", Underlined);
      Screen.Write_XY(25,15, Barrel_Water_Level.Image & "%", Underlined);
      Screen.Write_XY(2,16, "Rozkaz pompy", Underlined);
      Screen.Write_XY(22,16, "|", Underlined);
      Screen.Write_XY(2,17, "tloczacej", Underlined);
      Screen.Write_XY(22,17, "|", Underlined);
      Screen.Write_XY(25,17, Pump_In_Command'Img, Underlined);
      Screen.Write_XY(2,18, "Rozkaz pompy", Underlined);
      Screen.Write_XY(22,18, "|", Underlined);
      Screen.Write_XY(2,19, "wypompowujacej", Underlined);
      Screen.Write_XY(22,19, "|", Underlined);
      Screen.Write_XY(25,19, Pump_Out_Command'Img, Underlined);
      Screen.Write_XY(2,20,"-------------------------------------------------------", Bright);
      Screen.Write_XY(20,21, "Reszta", Underlined);
      Screen.Write_XY(2,22,"-------------------------------------------------------", Bright);
      Screen.Write_XY(2,23, "Drzwi zamkniete", Underlined);
      Screen.Write_XY(22,23, "|", Underlined);
      Screen.Write_XY(25,23, Door_Closed_State'Img, Underlined);
      Screen.Write_XY(2,24, "Drzwi zablokowane", Underlined);
      Screen.Write_XY(22,24, "|", Underlined);
         Screen.Write_XY(25,24, Door_Blocked_State'Img, Underlined);
         --Screen.Write_XY(1,25,"+-----------------------------------------------+", Bright);

      --Screen.Write_XY(3, 26, " Ctl-C .. Koniec; T. zadana -> D - w dol‚, G - w gore " & ASCII.ESC);
      Next := Next + Period;
    end loop;
  exception
      when E:others =>
        Put_Line("Error: Task Interfejs_U");
        Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
  end Printing;

--    protected  Button
--        with Priority => (System.Default_Priority+7) is
--      procedure Give(Zn : out Character);
--    end Button;
--
--    protected body Button is
--      procedure Give(Zn : out Character) is
--      begin
--        Get_Immediate(Zn);
--      end Give;
--    end Button;
--
--    protected Button_
--        with Priority => (System.Default_Priority+7) is
--      entry Czekaj(SK : out Stany_Buttona);
--      procedure Wstaw(SK : in Stany_Buttona);
--    private
--      SKL : Stany_Buttona;
--      Jest_Nowy : Boolean := False;
--    end Button_Temp_Zew;
--
--    protected body Button_Temp_Zew is
--      entry Czekaj(SK : out Stany_Buttona) when Jest_Nowy is
--      begin
--        Jest_Nowy := False;
--        SK := SKL;
--      end Czekaj;
--      procedure Wstaw(SK : in Stany_Buttona) is
--      begin
--        Jest_Nowy := True;
--        SKL := SK;
--      end Wstaw;
--    end Button_Temp_Zew;

--    task Klawiatura
--      with Priority => (System.Default_Priority+5);
--
--    task body Klawiatura is
--      Zn   : Character;
--    begin
--      loop
--        Button.Podaj(Zn);
--        Screen.Write_XY(35,8,"Button");
--        Screen.Write_XY(36,9, " " & Zn & " ", Negative);
--        if Zn in 'g'|'G'|'A' then
--          Button_Temp_Zew.Wstaw(W_Gore);
--        elsif Zn in 'd'|'D'|'B' then
--          Button_Temp_Zew.Wstaw(W_Dol);
--        end if;
--      end loop;
--    end Klawiatura;
--
--    task Ustaw_Temp_Zew
--      with Priority => (System.Default_Priority+6);
--
--    task body Ustaw_Temp_Zew is
--      Temp : Float := 0.0;
--      SKL  : Stany_Buttona;
--    begin
--      loop
--        Button_Temp_Zew.Czekaj(SKL);
--        case SKL is
--          when W_Gore =>
--            Temp := Temp_Zadana.Pobierz + 1.0;
--            if Temp in Zakres_Temp_Wew then
--              Temp_Zadana.Wstaw( Temp );
--            end if;
--          when W_Dol =>
--            Temp := Temp_Zadana.Pobierz - 1.0;
--            if Temp in Zakres_Temp_Wew then
--              Temp_Zadana.Wstaw( Temp );
--            end if;
--        end case;
--      end loop;
--    end Ustaw_Temp_Zew;

begin
  -- inicjowanie
  Screen.Clear;
end Terminal;
