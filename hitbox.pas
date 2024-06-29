(* HIT BOX *)

uses crt, joystick, fastgraph;

type
	TBox = record
		x,y, w, h: byte;
	       end;

var
	b1, b2: TBox;

	v: byte;


function hitBox(var rect1, rect2: TBox): Boolean;
begin

  if
    (rect1.x < byte(rect2.x + rect2.w)) and
    (byte(rect1.x + rect1.w) > rect2.x) and
    (rect1.y < byte(rect2.y + rect2.h)) and
    (byte(rect1.y + rect1.h) > rect2.y)
  then
    Result:=true
  else
    Result:=false;

end;


procedure drawBox(b: TBox; c: byte);
begin

 SetColor(c);

 MoveTo(b.x, b.y);
 LineTo(b.x + b.w, b.y);
 LineTo(b.x + b.w, b.y + b.h);
 LineTo(b.x, b.y + b.h);
 LineTo(b.x, b.y);

end;


begin
 InitGraph(15);

 b1.x:=85;	// moveable box
 b1.y:=75;
 b1.w:=25;
 b1.h:=20;

 b2.x:=50;	// static box
 b2.y:=54;
 b2.w:=33;
 b2.h:=16;

 drawBox(b1, 1);
 drawBox(b2, 2);

 repeat

  pause;

  v:=joy_1;

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

   writeln(hitBox(b1,b2));

  end;


 until false;

end.