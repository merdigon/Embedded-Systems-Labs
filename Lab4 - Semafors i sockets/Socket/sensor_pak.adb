-- sensor_pak.adb
-- materiały dydaktyczne
-- Jacek Piwowarczyk

with Ada.Text_IO;
use  Ada.Text_IO;
with Ada.Numerics.Float_Random;
use Ada.Numerics.Float_Random;
with Ada.Exceptions;
use Ada.Exceptions;
with GNAT.Sockets; use GNAT.Sockets;
with Ada.Real_Time;
use Ada.Real_Time;

package body Sensor_Pak is

  task body Sens is
    Nastepny : Ada.Real_Time.Time;
    Okres   : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(1200);
    G       : Generator;
    Address : Sock_Addr_Type;
    Socket  : Socket_Type;
    Channel : Stream_Access;
  begin
    Reset(G);
    Nastepny := Ada.Real_Time.Clock;
    Address.Addr := Addresses (Get_Host_By_Name (Host_Name), 1);
    Address.Port := 5876;
    Create_Socket (Socket);
    Set_Socket_Option (Socket, Socket_Level, (Reuse_Address, True));
    Connect_Socket (Socket, Address);
    loop
      Put_Line("Sensor: czekam okres ...");
      delay until Nastepny;
      Channel := Stream (Socket);
      --  Send message to kontroler
      Put_Line("Sensor: -> wysyłam dane ...");
      Float'Output (Channel, Random(G) );
      --  Receive and print message from Kontroler
      Put_Line ("Sensor: <-" & String'Input (Channel));
      Nastepny := Nastepny + Okres;
    end loop;
  exception
    when E:others =>
      Close_Socket (Socket);
      Put_Line("Error: Zadanie Sensor");
      Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
  end Sens;

end Sensor_Pak;
