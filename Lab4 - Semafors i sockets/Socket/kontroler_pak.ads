-- kontroler_pak.ads
-- materiały dydaktyczne
-- Jacek Piwowarczyk

pragma Profile(Ravenscar);

with System;

package Kontroler_Pak is

  task Kontrol is
    pragma Priority(System.Default_Priority);
  end Kontrol;

end Kontroler_Pak;
