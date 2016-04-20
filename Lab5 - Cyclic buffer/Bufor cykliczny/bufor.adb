pragma Profile(Ravenscar);

with System;

package body Bufor is

	type Buf is array (1..10) of Float;

	protected Buff is 
		procedure Place(Item : in Float; Success : out Boolean); 
		procedure Extract(Item : out Float; Success : out Boolean); 
	private		
		BufforCykl: Buf;
		InPointer : Integer := 1;
		OutPointer : Integer := 1;
      		Buffer_Full : Boolean := False;
      		Buffer_Empty : Boolean := True;
	end Buff; 

	Non_Full, Non_Empty : Ada.Synchronous_Task_Control.Suspension_Object;

	procedure Place_Item(Item : Float) is
      		OK : Boolean;
	begin
      		Buff.Place(Item, OK);
 		if not OK then
            		Ada.Synchronous_Task_Control.Suspend_Until_True(Non_Full);
            		Buff.Place(Item, OK); 
		end if;
      		Ada.Synchronous_Task_Control.Set_True(Non_Empty);
	end Place_Item;

	procedure Extract_Item(Item : out Float) is
      		OK : Boolean;
	begin
      		Buff.Extract(Item, OK);
      		if not OK then
         		Ada.Synchronous_Task_Control.Suspend_Until_True(Non_Empty);
         		Buff.Extract(Item, OK); 
		end if;
      		Ada.Synchronous_Task_Control.Set_True(Non_Full);
	end Extract_Item;

	protected body Buff is
		procedure Place(Item    : in Float; Success : out Boolean) is
		begin
         		Success := not Buffer_Full;
 			if not Buffer_Full then
            			Buffer_Empty := False;
				BufforCykl(InPointer) := Item;
				InPointer := InPointer + 1;
				if InPointer > 10 then InPointer := 1; end if;
				if OutPointer = InPointer then Buffer_Full := True; end if;
			end if;
		end Place;

		procedure Extract(Item   : out Float; Success: out Boolean) is
		begin
         		Success := not Buffer_Empty;
 			if not Buffer_Empty then
            			Buffer_Full := False;
				Item := BufforCykl(OutPointer);
				OutPointer := OutPointer + 1;
				if OutPointer > 10 then OutPointer := 1; end if;
				if OutPointer = InPointer then Buffer_Empty := True; end if;
			end if;
		end Extract;
	end Buff; 

end Bufor;

