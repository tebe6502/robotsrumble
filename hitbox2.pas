(* HIT BOX 2 *)

uses crt, joystick, fastgraph;

type
	TBox = record
		x,y, w, h: byte;
	       end;

	TColision = (left=1, right=2, top=4, bottom=8, nohit=0);

var
	b1, b2: TBox;

	v: byte;
	
	c: TColision;
	
{
    x,y           
     *---------------------------*
     |                           |
     |             * center      | h
     |                           |
     *---------------------------*
                   w
}
     
function hitBox(var A, B: TBox): TColision;
var w,h, _w, _h: byte;
    dx,dy,wy,hx: smallint;
begin

Result:=nohit;

w := byte(A.w + B.w) shr 1;
h := byte(A.h + B.h) shr 1;

dx := (A.x + A.w shr 1) - (B.x + B.w shr 1);	// center X

if dx >= 0 then
 _w := dx
else
 _w := -dx;

dy := (A.y + A.h shr 1) - (B.y + B.h shr 1);	// center Y

if dy >= 0 then
 _h := dy
else
 _h := -dy;
 

if (_w <= w) and (_h <= h) then begin

    (* collision! *)
    wy := w * dy;
    hx := h * dx;

    if (wy > hx) then begin

        if (wy > smallint(-hx)) then
            (* collision at the bottom *)
	    Result := bottom
        else
            (* on the left *)
	    Result := left;

    end else

        if (wy < smallint(-hx)) then
            (* on the top *)
	    Result := top
        else
            (* at the right *)
	    Result := right;

end;

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

   c := hitBox(b1,b2);
   
   case c of
    1: writeln('left');
    2: writeln('right');
    4: writeln('top');
    8: writeln('bottom');
   else
    writeln;
   end;
  

  end;


 until false;

end.