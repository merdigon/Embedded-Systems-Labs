pragma Profile(Ravenscar);

with System;

package body Bufor is

	procedure Zapisz (value : in Float) is
	begin
		Suspend_Until_True(Sem_We);
		TotalValue := value;
		Set_False(Sem_We);
		Set_True(Sem_Wy);
	end Zapisz;

	procedure Pobierz (valueToAss : out Float) is
	begin
		Suspend_Until_True(Sem_Wy);
		valueToAss := TotalValue;
		Set_False(Sem_Wy);
		Set_True(Sem_We);
	end Pobierz;
begin
	Set_True(Sem_We);
	Set_False(Sem_Wy);
end Bufor;
