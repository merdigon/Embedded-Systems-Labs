-- TestInt

with Ada.Text_IO, TIPak;
use Ada.Text_IO, TIPak;

procedure TestInt is
begin
  Put_Line("kill -SIGUSR1 <psid>, Ctrl+C Koniec");
  Put_Line("kill -SIGUSR2 <psid>, Ctrl+C Koniec");
	loop
		null;
	end loop;
end TestInt;

