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

   procedure WriteExtendedScreen is
      Door_Closed_State : String := " ";
      Door_Blocked_State : String := " ";
   begin
      Door_Closed_State := Door_Closed.Image;
      Door_Blocked_State := Door_Blocked.Image;
      Screen.Clear;
      Screen.Write_XY(1,1,"+---------------------------- Symulacja pralki ---------------------------+", Bright);
      for W in 2..21 loop
         Screen.Write_XY(1, W ,"|", Bright);
         Screen.Write_XY(75, W ,"|", Bright);
      end loop;
      Screen.Write_XY(37,2, "Beben", Underlined);
      Screen.Write_XY(2,3,"-------------------------------------------------------------------------", Bright);
      Screen.Write_XY(2,4, "Predkosc", Underlined);
      Screen.Write_XY(22,4, "|", Underlined);
      Screen.Write_XY(25,4, Barrel_Rotation_State.ImageSpeed & " obr/s", Underlined);
      Screen.Write_XY(40,4, "|", Bright);
      Screen.Write_XY(2,5, "Kierunek", Underlined);
      Screen.Write_XY(22,5, "|", Underlined);
      Screen.Write_XY(25,5, Barrel_Rotation_State.ImageDirection, Underlined);
      Screen.Write_XY(40,5, "|", Bright);
      Screen.Write_XY(41,4, "Rozkaz", Underlined);
      Screen.Write_XY(57,4, "|", Underlined);
      Screen.Write_XY(60,4, Barrel_Command'Img, Underlined);
      Screen.Write_XY(2,6,"-------------------------------------------------------------------------", Bright);
      Screen.Write_XY(37,7, "Grzalka", Underlined);
      Screen.Write_XY(2,8,"-------------------------------------------------------------------------", Bright);
      Screen.Write_XY(2,9, "Temp. wody", Underlined);
      Screen.Write_XY(22,9, "|", Underlined);
      Screen.Write_XY(25,9, Barrel_Water_Temp.Image & "C", Underlined);
      Screen.Write_XY(40,9, "|", Bright);
      Screen.Write_XY(42,9, "Czas rzeczywisty", Underlined);
      Screen.Write_XY(58,9, "  " & Integer'Image(SimulationTime * 36) & "s", Underlined);
      Screen.Write_XY(2,10, "Rozkaz", Underlined);
      Screen.Write_XY(22,10, "|", Underlined);
      Screen.Write_XY(25,10, Heater_Command'Img, Underlined);
      Screen.Write_XY(40,10, "|", Bright);
      Screen.Write_XY(42,10, "Czas symulacji", Underlined);
      Screen.Write_XY(58,10, "  " & SimulationTime'Img & "s", Underlined);
      Screen.Write_XY(2,11,"-------------------------------------------------------------------------", Bright);
      Screen.Write_XY(37,12, "Pompa", Underlined);
      Screen.Write_XY(2,13,"-------------------------------------------------------------------------", Bright);
      Screen.Write_XY(2,14, "Poziom wody", Underlined);
      Screen.Write_XY(22,14, "|", Underlined);
      Screen.Write_XY(25,14, Barrel_Water_Level.Image & "%", Underlined);
      Screen.Write_XY(40,14, "|", Bright);
      Screen.Write_XY(2,15, "Rozkaz pompy", Underlined);
      Screen.Write_XY(22,15, "|", Underlined);
      Screen.Write_XY(40,15, "|", Bright);
      Screen.Write_XY(2,16, "tloczacej", Underlined);
      Screen.Write_XY(22,16, "|", Underlined);
      Screen.Write_XY(25,16, Pump_In_Command'Img & " ", Underlined);
      Screen.Write_XY(40,16, "|", Bright);
      Screen.Write_XY(41,14, "Rozkaz pompy", Underlined);
      Screen.Write_XY(57,14, "|", Underlined);
      Screen.Write_XY(41,15, "wypompowujacej", Underlined);
      Screen.Write_XY(57,15, "|", Underlined);
      Screen.Write_XY(60,15, Pump_Out_Command'Img & " ", Underlined);
      Screen.Write_XY(2,17,"-------------------------------------------------------------------------", Bright);
      Screen.Write_XY(37,18, "Reszta", Underlined);
      Screen.Write_XY(2,19,"-------------------------------------------------------------------------", Bright);
      Screen.Write_XY(2,20, "Drzwi zamkniete", Underlined);
      Screen.Write_XY(22,20, "|", Underlined);
      Screen.Write_XY(25,20, Door_Closed_State, Underlined);
      Screen.Write_XY(40,20, "|", Bright);
      Screen.Write_XY(2,21, "Drzwi zablokowane", Underlined);
      Screen.Write_XY(22,21, "|", Underlined);
      Screen.Write_XY(25,21, Door_Blocked_State, Underlined);
      Screen.Write_XY(41,20, "Poziom proszku", Underlined);
      Screen.Write_XY(57,20, "|", Underlined);
      Screen.Write_XY(60,20, Powder_Level.Image, Underlined);
      Screen.Write_XY(41,21, "Poziom plynu", Underlined);
      Screen.Write_XY(57,21, "|", Underlined);
      Screen.Write_XY(60,21, Wash_Liquid_Level.Image, Underlined);
      Screen.Write_XY(40,21, "|", Bright);
      Screen.Write_XY(1,22,"+-------------------------------------------------------------------------+", Bright);
   end WriteExtendedScreen;

   procedure RefreshExtendedScreen is
      Door_Closed_State : String := " ";
      Door_Blocked_State : String := " ";
   begin
      Door_Closed_State := Door_Closed.Image;
      Door_Blocked_State := Door_Blocked.Image;
      Screen.Write_XY(25,4, Barrel_Rotation_State.ImageSpeed & " obr/s", Underlined);
      Screen.Write_XY(25,5, Barrel_Rotation_State.ImageDirection, Underlined);
      Screen.Write_XY(60,4, "              ", Underlined);
      Screen.Write_XY(60,4, Barrel_Command'Img, Underlined);
      Screen.Write_XY(25,9, Barrel_Water_Temp.Image & "C", Underlined);
      Screen.Write_XY(58,9, "  " & Integer'Image(SimulationTime * 36) & "s", Underlined);
      Screen.Write_XY(25,10, "    ", Underlined);
      Screen.Write_XY(25,10, Heater_Command'Img, Underlined);
      Screen.Write_XY(58,10, "  " & SimulationTime'Img & "s", Underlined);
      Screen.Write_XY(25,14, Barrel_Water_Level.Image & "%", Underlined);
      Screen.Write_XY(25,16, "     ", Underlined);
      Screen.Write_XY(25,16, Pump_In_Command'Img, Underlined);
      Screen.Write_XY(60,15, "     ", Underlined);
      Screen.Write_XY(60,15, Pump_Out_Command'Img, Underlined);
      Screen.Write_XY(25,20, Door_Closed_State, Underlined);
      Screen.Write_XY(25,21, Door_Blocked_State, Underlined);
      Screen.Write_XY(60,20, Powder_Level.Image, Underlined);
      Screen.Write_XY(60,21, Wash_Liquid_Level.Image, Underlined);
   end RefreshExtendedScreen;

   procedure WriteUserInterface is
      PowderLvl : Integer := 0;
      LiqLvl    : Integer := 0;
   begin
      Screen.Write_XY(1,1,"+-----------------------+", Bright);
      if Currently_Pointed_User_Menu_Option = ECO then
         Screen.Write_XY(3,3,"-", Clean);
      elsif Currently_Pointed_User_Menu_Option = Normal then
         Screen.Write_XY(3,5,"-", Clean);
      elsif Currently_Pointed_User_Menu_Option = Extended then
         Screen.Write_XY(3,7,"-", Clean);
      elsif Currently_Pointed_User_Menu_Option = Powder then
         Screen.Write_XY(3,9,"-", Clean);
      elsif Currently_Pointed_User_Menu_Option = LiqLevel then
         Screen.Write_XY(3,11,"-", Clean);
	  else
         Screen.Write_XY(3,13,"-", Clean);
      end if;

      if Choosen_Washing_Type = ECO then
         Screen.Write_XY(5,3,"ECO", Underlined);
      else
         Screen.Write_XY(5,3,"ECO", Clean);
      end if;
      if Choosen_Washing_Type = Normal then
         Screen.Write_XY(5,5,"Normal", Underlined);
      else
         Screen.Write_XY(5,5,"Normal", Clean);
      end if;
      if Choosen_Washing_Type = Extended then
         Screen.Write_XY(5,7,"Extended", Underlined);
      else
         Screen.Write_XY(5,7,"Extended", Clean);
      end if;

      Screen.Write_XY(5,9,"Proszek", Clean);
      Screen.Write_XY(5,11,"Plyn", Clean);

      PowderLvl := Integer(Powder_Level.Output / 10.0);
      LiqLvl := Integer(Wash_Liquid_Level.Output / 10.0);	  
	  
      Screen.Write_XY(5,13,"Start", Clean);

      for W in 0..PowderLvl loop
         Screen.Write_XY(14+W, 9 ,"|", Bright);
      end loop;

      for W in 0..LiqLvl loop
         Screen.Write_XY(14+W, 11 ,"|", Bright);
      end loop;

      Screen.Write_XY(1,15,"+-----------------------+", Bright);
   end WriteUserInterface;

   task body Printing is
      Next : Ada.Real_Time.Time;
      Period    : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(400);
      Speed : Float := 0.0;
      Dire : CommonData.Direction := Left;
      Temp : Range_Proc_Temp := 0.0;
      Water_Level : Range_Proc_Temp := 0.0;

      Shift : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(50);
   begin
      Next := Ada.Real_Time.Clock + Shift;
      loop
         delay until Next;
         --Speed := Barrel_Rotation_State.ImageSpeed;
         --Dire := Barrel_Rotation_State.OutputDirection;
         --Temp := Barrel_Water_Temp.Output;
         --Water_Level := Barrel_Water_Level.Output;

		 if InterfaceToWriteKind = User then
			Screen.Clear;
			WriteUserInterface;
		else
			--Screen.Clear;
			--WriteExtendedScreen;
			RefreshExtendedScreen;
		end if;
			

         --Screen.Write_XY(3, 26, " Ctl-C .. Koniec; T. zadana -> D - w dol‚, G - w gore " & ASCII.ESC);
         Next := Next + Period;
      end loop;
   exception
      when E:others =>
         Put_Line("Error: Task Interfejs_U");
         Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
   end Printing;

      protected  Button
          with Priority => (System.Default_Priority+7) is
        procedure Give(Zn : out Character);
      end Button;
   
      protected body Button is
        procedure Give(Zn : out Character) is
        begin
          Get_Immediate(Zn);
        end Give;
      end Button;
   
      protected Button_Menu
          with Priority => (System.Default_Priority+7) is
        entry Czekaj(SK : out Stany_Buttona);
        procedure Wstaw(SK : in Stany_Buttona);
      private
        SKL : Stany_Buttona;
        Jest_Nowy : Boolean := False;
      end Button_Menu;
   
      protected body Button_Menu is
        entry Czekaj(SK : out Stany_Buttona) when Jest_Nowy is
        begin
          Jest_Nowy := False;
          SK := SKL;
        end Czekaj;
        procedure Wstaw(SK : in Stany_Buttona) is
        begin
          Jest_Nowy := True;
          SKL := SK;
        end Wstaw;
      end Button_Menu;

      task Klawiatura
        with Priority => (System.Default_Priority+5);
   
      task body Klawiatura is
        Zn   : Character;
      begin
        loop
          Button.Give(Zn);
          if Zn in 'w'|'W' then
            Button_Menu.Wstaw(W_Gore);
          elsif Zn in 's'|'S' then
            Button_Menu.Wstaw(W_Dol);
          elsif Zn in 'a'|'A' then
            Button_Menu.Wstaw(W_Lewo);
          elsif Zn in 'd'|'D' then
            Button_Menu.Wstaw(W_Prawo);
          elsif Zn in 'e'|'E' then
            Button_Menu.Wstaw(Space);
          end if;
        end loop;
      end Klawiatura;
   
      task Ustaw_Menu
        with Priority => (System.Default_Priority+6);
   
      task body Ustaw_Menu is
        SKL  : Stany_Buttona;
		Level : Float;
      begin
        loop
          Button_Menu.Czekaj(SKL);
          case SKL is
            when W_Gore =>
              case Currently_Pointed_User_Menu_Option is
				when Normal =>
					Currently_Pointed_User_Menu_Option := ECO;
				when Extended =>
					Currently_Pointed_User_Menu_Option := Normal;
				when Powder =>
					Currently_Pointed_User_Menu_Option := Extended;
				when LiqLevel =>
					Currently_Pointed_User_Menu_Option := Powder;
				when Start =>
					Currently_Pointed_User_Menu_Option := LiqLevel;
				when others =>
					null;
			  end case;
            when W_Dol =>
              case Currently_Pointed_User_Menu_Option is
				when ECO =>
					Currently_Pointed_User_Menu_Option := Normal;
				when Normal =>
					Currently_Pointed_User_Menu_Option := Extended;
				when Extended =>
					Currently_Pointed_User_Menu_Option := Powder;
				when Powder =>
					Currently_Pointed_User_Menu_Option := LiqLevel;
				when LiqLevel =>
					Currently_Pointed_User_Menu_Option := Start;
				when others =>
					null;
			  end case;
			when W_Lewo =>
				case Currently_Pointed_User_Menu_Option is
					when LiqLevel =>
						Level := Wash_Liquid_Level.Output;
						if Level >= 10.0 then
							Wash_Liquid_Level.Input(Level - 10.0);
							end if;
					when Powder =>
						Level := Powder_Level.Output;
						if Level >= 10.0 then
							Powder_Level.Input(Level - 10.0);
							end if;
					when others =>
						null;
				end case;
			when W_Prawo =>
				case Currently_Pointed_User_Menu_Option is
					when LiqLevel =>
						Level := Wash_Liquid_Level.Output;
						if Level <= 90.0 then
							Wash_Liquid_Level.Input(Level + 10.0);
							end if;
					when Powder =>
						Level := Powder_Level.Output;
						if Level <= 90.0 then
							Powder_Level.Input(Level + 10.0);
							end if;
					when others =>
						null;
				end case;
			when Space =>
				case Currently_Pointed_User_Menu_Option is
					when ECO => Choosen_Washing_Type := ECO;
					when Normal => Choosen_Washing_Type := Normal;
					when Extended => Choosen_Washing_Type := Extended;
					when Start => Door_Closed.Input(true); InterfaceToWriteKind := Extended; Screen.Clear; WriteExtendedScreen;
					when others =>	null;
				end case;
          end case;
        end loop;
      end Ustaw_Menu;

begin
   -- inicjowanie
   --WriteExtendedScreen;
   WriteUserInterface;
end Terminal;
