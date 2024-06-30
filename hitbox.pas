(* HIT BOX *)

uses crt, joystick, fastgraph;

type
	TBox = record
		x,y, w, h: byte;
	       end;

var
	b1, b2: TBox;

	v: byte;


{
    x,y           
     *---------------------------*
     |                           |
     |                           | h-eight
     |                           |
     *---------------------------*
                 w-idth
}

function hitBox(A, B: TBox): Boolean;
begin

  if
    (A.x < byte(B.x + B.w)) and
    (byte(A.x + A.w) > B.x) and
    (A.y < byte(B.y + B.h)) and
    (byte(A.y + A.h) > B.y)
  then
    Result:=true
  else
    Result:=false;

end;


procedure drawBox(B: TBox; c: byte);
begin

 SetColor(c);

 MoveTo(B.x, B.y);
 LineTo(B.x + B.w, B.y);
 LineTo(B.x + B.w, B.y + B.h);
 LineTo(B.x, B.y + B.h);
 LineTo(B.x, B.y);

end;


begin
 InitGraph(15);

 b1.x:=85;	// moveable box
 b1.y:=75;
 b1.w:=8;
 b1.h:=16;

 b2.x:=50;	// static box
 b2.y:=54;
 b2.w:=33;
 b2.h:=16;

 drawBox(b1, 1);
 drawBox(b2, 2);

 repeat

  pause;

  v:=joy_1;	// read joystick #1

  if v <> joy_none then begin

   drawBox(b1, 0);
   drawBox(b2, 2);

   case v of
       joy_up: dec(b1.y);
     joy_down: inc(b1.y);
     joy_left: dec(b1.x);
    joy_right: inc(b1.x);
   end;

   drawBox(b1, 1);

   writeln( hitBox(b1,b2) );

  end;


 until false;

end.