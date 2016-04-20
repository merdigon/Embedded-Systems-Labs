-- kontroler_pak.adb
-- materiały dydaktyczne
-- Jacek Piwowarczyk

with Ada.Text_IO;
use  Ada.Text_IO;
with Ada.Exceptions;
use Ada.Exceptions;
with GNAT.Sockets; use GNAT.Sockets;
with Ada.Real_Time;

package body Kontroler_Pak is

  task body Kontrol is
    Address  : Sock_Addr_Type;
    Server   : Socket_Type;
    Socket   : Socket_Type;
    Channel  : Stream_Access;
    Dane     : Float := 0.0;
  begin
    Address.Addr := Addresses (Get_Host_By_Name (Host_Name), 1);
    Address.Port := 5876;
    Create_Socket (Server);
    Set_Socket_Option (Server, Socket_Level, (Reuse_Address, True));
    Bind_Socket (Server, Address);
    Listen_Socket (Server);
    Put_Line ( "Kontroler: czekam na Sensor ....");
    Accept_Socket (Server, Socket, Address);
    Channel := Stream (Socket);
    loop
      Dane := Float'Input (Channel);
      Put_Line ("Kontroler: -> dane =" & Dane'Img);
      --  Komunikat do: Sensor
      String'Output (Channel, "OK: " & Dane'Img);
    end loop;
  exception
    when E:others => Put_Line("Error: Zadanie Kontrol");
      Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
  end Kontrol;

end Kontroler_Pak;
