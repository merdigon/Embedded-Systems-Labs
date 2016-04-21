-- webr_io.adb
-- materiały dydaktyczne
-- Jacek Piwowarczyk

with Ada.Text_IO;
use  Ada.Text_IO;
with Ada.Exceptions;
use Ada.Exceptions;
with Ada.Real_Time;
with Ada.Strings.Unbounded;
use Ada.Strings.Unbounded;
with Ada.Strings.Fixed;
use Ada.Strings.Fixed;
with Ada.Strings;
use Ada.Strings;
with Ada.Streams;
use Ada.Streams;

package body WebR_IO is

  NL : Character := ASCII.LF;
  CRLF : String := ASCII.CR & ASCII.LF;
  Pre_Body : String :=
  "HTTP/1.1 200 OK" & NL & 
  "Content-Type: text/html" & NL &  
   CRLF &

  "<!DOCTYPE html>" & NL &
  "<html>" & NL &
  "  <head>" & NL &
  "    <meta http-equiv='Content-Type' content='text/html; charset = utf-8'/>" & NL &
  "     <title>Web Ravenscar Text IO lib</title>" & NL &
  "  </head>" & NL &
  "<meta HTTP-EQUIV='refresh' content='"&Web_Okres_Str&"; url='../'>" & NL & 
  "<body >" & NL&
  --  "<h1>Test OK !! </h1>" & NL&     
  " <div id=""webRtext"">"& NL ;  
  
  Post_Body : String :=
  " </div>"& NL &
  "</body>  " & NL;
  
  Tresc_Strony : Unbounded_String := To_Unbounded_String("");
   
  protected Strona_WWW is
    procedure Put(S : in String);
    procedure Put_Line(S : in String);
    procedure Clear;
  end Strona_WWW;  
  
  procedure Pisz(S : in String) is
  begin
    Strona_WWW.Put(S);
  end Pisz;  
  procedure PiszNL(S : in String) is
  begin
    Strona_WWW.Put_Line(S);
  end PiszNL;  
  procedure Czysc is
  begin
    Strona_WWW.Clear;
  end Czysc;  
  
  protected body Strona_WWW is
  procedure Put(S : in String) is
  begin
    Tresc_Strony := Tresc_Strony & To_Unbounded_String(S);
  end Put;  
  procedure Put_Line(S : in String) is
  begin
    Put(S & "<br>");  
  end Put_Line;                   
  procedure Clear is
  begin
    Tresc_Strony := To_Unbounded_String("");
  end Clear;  
  end Strona_WWW;
  
  task Serwer_WWW with
    Priority => System.Default_Priority;
  
  task body Serwer_WWW is
    Address  : Sock_Addr_Type;
    Server   : Socket_Type;
    Socket   : Socket_Type;
    Channel  : Stream_Access;
    Dane   : String(1..256) := (others => ' '); 
  begin
    Address.Addr := Addresses (Get_Host_By_Name (Host_Name), 1);
    --PiszNL ( "Host Name: " & Host_Name);
    Put_Line("Serwer WWW: start Ok");
    --Address.Addr := Addresses (Get_Host_By_Name ("localhost"), 1);    
    Address.Port := Port_Nr; --5080;
    Put_Line("Port nr = " & Port_Nr'Img);
    Put_Line("Koniec : Ctrl_C ");
    Create_Socket (Server);
    Set_Socket_Option (Server, Socket_Level, (Reuse_Address, True));
    Bind_Socket (Server, Address);
    Listen_Socket (Server);  
   
    loop      
      Accept_Socket (Server, Socket, Address);
      Channel := Stream (Socket);
      String'Read(Channel, Dane );
      --PiszNL("<b>Serwer WWW: -> dane = </b>" &  Trim(Dane, Both) );
      String'Write(Channel, Pre_Body & To_String(Tresc_Strony) & Post_Body );
      Close_Socket(Socket);
    end loop;
  exception
    when E:others => Put_Line("Error: Zadanie Serwer WWW");
      Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
  end Serwer_WWW;

end WebR_IO;
