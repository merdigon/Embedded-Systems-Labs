-- sensor_pak.ads
-- materiały dydaktyczne
-- Jacek Piwowarczyk

pragma Profile(Ravenscar);

with System;

package Sensor_Pak is

  task Sens is
    pragma Priority(System.Default_Priority);
  end Sens;

end Sensor_Pak;
