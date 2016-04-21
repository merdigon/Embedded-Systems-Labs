-- terminal.ads

pragma Profile(Ravenscar);
with System;

package Terminal is

  type Atrybuty is (Czysty, Jasny, Podkreslony, Negatyw, Migajacy, Szary);

  protected Ekran
      with Priority => (System.Default_Priority+9) is
    procedure Pisz_XY(X,Y: Positive; S: String; Atryb : Atrybuty := Czysty);
    procedure Czysc;
  end Ekran;

end Terminal;
