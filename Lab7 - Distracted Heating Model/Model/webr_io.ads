-- webr_io.ads
-- materiały dydaktyczne
-- Jacek Piwowarczyk

pragma Profile(Ravenscar);

with System;
with GNAT.Sockets; use GNAT.Sockets;

package WebR_IO is

  Web_Okres_Str : String := "1.2"; -- okres ~ sekundy
  Port_Nr : Port_Type := 5080;

  procedure Pisz(S : in String);
  procedure PiszNL(S : in String);
  procedure Czysc;

end WebR_IO;
