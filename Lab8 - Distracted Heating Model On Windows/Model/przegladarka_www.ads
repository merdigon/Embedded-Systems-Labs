-- przegladarka_www.ads

pragma Profile(Ravenscar);
with System;

package Przegladarka_WWW is

  task Wypisanie
    with Priority => (System.Default_Priority+2);

end Przegladarka_WWW;
