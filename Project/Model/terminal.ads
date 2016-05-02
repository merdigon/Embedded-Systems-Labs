-- terminal.ads

pragma Profile(Ravenscar);
with System;
with WashingMachine;
use WashingMachine;
with NT_Console; use NT_Console;

package Terminal is

  type Atribute is (Clean, Bright, Underlined, Negative, Blinking, Gray);

  protected Screen
      with Priority => (System.Default_Priority+9) is
    procedure Write_XY(X,Y: Positive; S: String; Atryb : Atribute := Clean);
    procedure Clear;
  end Screen;

end Terminal;
