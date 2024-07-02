unit control;


interface

const

	left_magnet_px = 5;
	right_magnet_px = 25;

	empty_tile = 0;

	py_limit = 22;

	delay_value = 6;


var
	fireBtn, esc: Boolean;

	joy, joyDelay, l_magnet, r_magnet: byte;


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
 
  if l_magnet > py_limit then exit;
  
  p:=pointer(dpeek(88) + byte(l_magnet + dy)*40 + left_magnet_px);
  
  Result:= (p[0] = empty_tile);
  
 end else begin
 
  if r_magnet > py_limit then exit;
 
  p:=pointer(dpeek(88) + byte(r_magnet + dy)*40 + right_magnet_px + 1);
  
  Result:= (p[0] = empty_tile);
 
 end;
 

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


	if a = joy then begin

	  if joyDelay >= 1 then begin dec(joyDelay) ; exit end;

	  joy:=$ff;

	end else begin
	  joyDelay:=delay_value;
	  joy:=a;
	end;


	if onKey < 128 then begin

	 fireBtn:=true;

	 case onKey of
	  KEY_ESC: esc:=true;

	  KEY_Q: a:=joy_up;
	  KEY_A: a:=joy_down;
	  
	  KEY_P: begin fireBtn:=false; a:=joy_up end;
	  KEY_L: begin fireBtn:=false; a:=joy_down end;
	  
	 end;

	 onKey:=$80;
	end;


	if fireBtn then begin						{left magnet}
	
	  case a of
	      joy_up: if allow(0, -1) then begin dec(l_magnet, 3) end;	{up}
	    joy_down: if allow(0, 2) then begin inc(l_magnet, 3); end;	{down}
	  end;
	  
	end else							{right magnet}

	  case a of
	      joy_up: if allow(1, -1) then dec(r_magnet, 3);		{up}
	    joy_down: if allow(1, 2) then inc(r_magnet, 3);		{down}
	  end;
	
end;


end.
