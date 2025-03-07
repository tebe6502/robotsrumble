unit control;


interface

type
	TMagnet = record
		y, old: byte;
	       end;

const

	left_magnet_px = 5;
	right_magnet_px = 25;

	empty_tile = 0;

	py_limit = 22;

	delay_value = 6;


var
	fireBtn, keyboard, esc: Boolean;

	joy, joyDelay: byte;
	
	l_magnet, r_magnet: TMagnet;


	function anyKey: Boolean; assembler;
	procedure JoyScan;


implementation

uses keycode, joystick, atari;


(*-----------------------------------------------------------*)

function allow(m: byte; dy: byte): Boolean;
var p: PByte register;
begin

	asm
	  fxs FX_MEMS #$00
	end;

 Result := false;

 if m = 0 then begin
 
  if l_magnet.y > py_limit then exit;
  
  p:=pointer(dpeek(88) + byte(l_magnet.y + dy)*40 + left_magnet_px);
  
  Result:= (p[0] = empty_tile);
  
 end else begin
 
  if r_magnet.y > py_limit then exit;
 
  p:=pointer(dpeek(88) + byte(r_magnet.y + dy)*40 + right_magnet_px + 1);
  
  Result:= (p[0] = empty_tile);
 
 end;
 

end;

(*-----------------------------------------------------------*)

function anyKey: Boolean; assembler;
asm
	lda:cmp:req 20

	lda #1
	sta Result

	lda $d20f
	and #4
	bne skp

	beq stop

skp	lda trig0
	bne @exit

stop	sta Result
end;

(*-----------------------------------------------------------*)

Procedure JoyScan;
var onKey: byte = $80;
    a: byte;


procedure get_key; assembler;
asm
	lda $d20f
	and #4
	bne @exit

	lda $d209

	cmp onKey_: #0
	bne skp

	ldy delay: #delay_value
	dey
	sty delay
	bne @exit
skp
	sta onKey
	sta onKey_

	mva #delay_value delay
end;


BEGIN
	fireBtn:= Boolean(trig0);

	get_key;

	a:=porta and $0f;//joy_1;
	
					//onKey:=onKey and %00111111;

	if keyboard then fireBtn:=false;


	if a = joy then begin

	  if joyDelay >= 1 then begin dec(joyDelay) ; exit end;

	  joy:=$ff;

	end else begin
	  joyDelay:=delay_value;
	  joy:=a;
	  
	  //if a <> joy_none then keyboard:=false;
	end;


	if onKey < 128 then begin

	 fireBtn:=true;

	 case onKey of
	  KEY_ESC: esc:=true;

	  KEY_Q: begin a:=joy_up; keyboard:=false end;
	  KEY_A: begin a:=joy_down; keyboard:=false end;
	  
	  KEY_P: begin fireBtn:=false; a:=joy_up; keyboard:=true end;
	  KEY_L: begin fireBtn:=false; a:=joy_down; keyboard:=true end;
	  
	 end;

	 onKey:=$80;
	end;
	


	if fireBtn then begin							{left magnet}
	
	  case a of
	      joy_up: if allow(0, -1) then begin dec(l_magnet.y, 3) end;	{up}
	    joy_down: if allow(0, 2) then begin inc(l_magnet.y, 3); end;	{down}
	  end;
	  
	end else								{right magnet}

	  case a of
	      joy_up: if allow(1, -1) then dec(r_magnet.y, 3);			{up}
	    joy_down: if allow(1, 2) then inc(r_magnet.y, 3);			{down}
	  end;
	
end;


end.
