-- terminal.ads

pragma Profile(Ravenscar);
with System;
with WashingMachine;
use WashingMachine;
with NT_Console; use NT_Console;

package Terminal is

   type Atribute is (Clean, Bright, Underlined, Negative, Blinking, Gray);
   type UserMenuOption is (ECO, Normal, Extended, Powder, LiqLevel, Start);
   type Stany_Buttona is (W_Gore, W_Dol, W_Lewo, W_Prawo, Space);

  protected Screen
      with Priority => (System.Default_Priority+9) is
    procedure Write_XY(X,Y: Positive; S: String; Atryb : Atribute := Clean);
    procedure Clear;
   end Screen;

   Currently_Pointed_User_Menu_Option : UserMenuOption := ECO with Atomic;

end Terminal;
