
// dlaczego dla makra  $define nie mozna wstawic kodu asm
// nie moze byc dostepu do tablicy 'enemy[] od record'  jako enemy.x itd.


(*

Robots Rumble

https://www.file-hunter.com/MSXdev/index.php?id=roborumble

- kazdy level sklada się z 78 tilesow (78 znakow), od
- 'cmap1', 'cmap2' to mapa kolorów dla tilesow
- 'id' to identyfikator tilesow

kazda lokacja przegladana jest w poszukiwaniu tilesow reprezentujacych
prawy/lewy magnes, baterie etc.

*)


uses crt, atari, joystick, control, ctm, vsprite, vbxe;

{$define romoff}

{$r robots.rc}

type
	TEnemy = record
		 x,y: byte;
		 blit: byte;
		 adx: byte;
		 kind: byte;
		 frm: byte;
		 src: cardinal;
		 end;

	PTEnemy = ^TEnemy;

const
	cmap_width = 160;		// color map width 40 * 4 = 160


	left_magnet_code = 1;		// wspolne kody tilesow
	right_magnet_code = 24;
	robot_code = 5;
	battery_code = 11;

	box_corner = 45;
	box_top = 46;
	box_left = 47;
	box_right = 48;
	box_bottom = 49;


	enemyrobot_code = 19;
	enemyeel_code = 13;

	lmag_tile_code = 1;		// 1,2,3,4
	rmag_tile_code = 24;		// 24,25,26,27

	cmap_adr: array of pointer = [ {$eval 24,"VBXE_WINDOW+:1*cmap_width"} ];

	mul_40: array of word = [ {$eval 24,":1*40"} ];

//	mul_320: array of word = [ {$eval 256,":1*320"} ];


{$i id.inc}			// kody identyfikacji tilesow niezalezne od levelu

//	id_empty= 1;
//	id_downbar = 2;
//	id_death = 3;
//	id_lava = 4;
//	id_elevator = 5;
//	id_battery = 6;

var
	vram: TVBXEMemoryStream;

	robot_x, robot_y, room, lvl, lives, power, enemy_cnt: byte;
	battery_x, battery_y: byte;

	next_room, next_level: Boolean;
	death_robot: Boolean;
	elevator: Boolean;

	tick: byte;

	clock: word absolute $13;

	txt: TString;

	enemy0, enemy1, enemy2, enemy3, enemy4: TEnemy;

	enemy: array [0..4] of PTEnemy;


(*-----------------------------------------------------------*)

procedure tile_panel(t: byte; x,y: byte);
var p: PByte register;
begin

	asm
	  fxs FX_MEMS #$00
	end;

	p:=pointer(dpeek(88) + mul_40[y] + x);


	p[0] := t ;//+ panel_ofset;


	asm
	 fxs FX_MEMS #$81
	end;

	p:=cmap_adr[y] + x shl 2 + 1;

	p[0]:=color1;
	p[1]:=color2;

end;

(*-----------------------------------------------------------*)

procedure tile(t: byte; x,y: byte);
var p: PByte register;
begin

	asm
	  fxs FX_MEMS #$00
	end;

	p:=pointer(dpeek(88) + mul_40[y] + x);

	p[0] := t;


	asm
	 fxs FX_MEMS #$81
	end;

	p:=cmap_adr[y] + x shl 2 + 1;

	p[0]:=cmap1[t];
	p[1]:=cmap2[t];

end;

(*-----------------------------------------------------------*)

procedure doText(x,y: byte);
var i: byte;
    v: byte;
begin

 for i:=1 to length(txt) do begin
  v:=byte(txt[i]);

  case v of
             ord(' '): v:=0;
   ord('0')..ord('9'): dec(v, 21);
   ord('A')..ord('Z'): dec(v, 64);
  end;

  inc(v, panel_ofset);

  tile_panel(v, x, y);
  inc(x);
 end;

end;

(*-----------------------------------------------------------*)

procedure doStatusPanel;
var i,j, v: byte;
begin

 for j:=0 to 23 do
  for i:=0 to 7 do begin

   TextColor($61 + j shr 2);

   if (j=3) or (j=10) then TextColor($7c);	// robots ; lvl

   if (j=4) or (j=7) then TextColor($48);	// rumble ; planet

   if j >= 12 then TextColor($0e);

   if (i=3) and (j=13) then TextColor($7a);	// battery
   if (i=4) and (j=13) then TextColor($26);	// battery

   if (i=0) or (i=7) or (j=0) or (j=23) then TextColor($42);

   v:=panel_map[i+j*8];

   if v < box_corner then begin
    //TextColor($42);
    tile(v, i+28, j);
   end else
    tile_panel(v, i+28, j);

  end;

end;

(*-----------------------------------------------------------*)

procedure restoreBlit;
begin

 SrcBlit(0, src0);

 enemy0.kind:=0;
 enemy1.kind:=0;
 enemy2.kind:=0;
 enemy3.kind:=0;
 enemy4.kind:=0;

end;


procedure wellDoneMessage;
var i, j: byte;
begin

  restoreBlit;

  txt:=' ';

  for j:=0 to 4 do
   for i:=left_magnet_px to 26 do doText(i, 8+j);

  TextColor($ca);

  txt:='WELL DONE';
  doText(11, 9);

  txt:='READY FOR NEXT PLANET';
  doText(left_magnet_px+1, 11);

end;

(*-----------------------------------------------------------*)

procedure endGameMessage;
begin
	restoreBlit;

	if power = 0 then begin
	  txt:='           ';
	  doText(11,10);
	  doText(11,12);

	  txt:=' POWER OFF ';
	end else
	if lives=1 then begin
	  txt:='           ';
	  doText(11,10);
	  doText(11,12);

	  txt:=' GAME OVER '
	end else begin
	  txt:='          ';
	  doText(11,10);
	  doText(11,12);

	  txt:=' BAD LUCK ';
	end;

 TextColor($ca);
 doText(11,11);
end;

(*-----------------------------------------------------------*)

procedure doPowerFull;
begin
  txt:=#42#43;		// energy status bar

  TextColor($ba);
  doText(31, 16);
  doText(31, 17);

  TextColor($fc);
  doText(31, 18);
  doText(31, 19);

  TextColor($28);
  doText(31, 20);
  doText(31, 21);

  power:=6;
  clock:=0;

end;

(*-----------------------------------------------------------*)

procedure doStatusPower;
begin

 txt:='  ';

 doText(31, 16+5-power);

end;

(*-----------------------------------------------------------*)

procedure doStatus;
var v: byte;
begin

 TextColor($0e);

 v:=6 - room;

 str(v, txt);
 doText(32, 10);	// room

 str(lives, txt);
 doText(34, 10);	// lives

 case lvl of
  0: txt:='EARTH2';
  1: txt:='NEBULA';
  2: txt:='ALTAIR';
  3: txt:='BOWIER';
 end;

 doText(29,8);

 if power = 6 then doPowerFull;

end;

(*-----------------------------------------------------------*)

procedure robotLifeIcons;
var p: Pbyte;
    x, y: byte;
begin
	asm
	  fxs FX_MEMS #$00
	end;

	x:=(robot_x-8) shr 3;
	y:=robot_y shr 3;

	p:=pointer(dpeek(88) + x + mul_40[y] + 4 + 40);

	p[0]:=empty_tile;
	p[1]:=empty_tile;
	p[40]:=empty_tile;
	p[41]:=empty_tile;

	if lives < 3 then begin

	  p[4]:=empty_tile;
	  p[5]:=empty_tile;
	  p[44]:=empty_tile;
	  p[45]:=empty_tile;

	end;

	if lives < 2 then begin

	  p[2]:=empty_tile;
	  p[3]:=empty_tile;
	  p[42]:=empty_tile;
	  p[43]:=empty_tile;

	end;

end;

(*-----------------------------------------------------------*)

procedure newRoom;
var j, py, adx: byte;
    ofs: word;
    m: Pbyte ;
    p: PByte register;
    scr: PByte register;


   procedure row;
   var v, i, x: byte;
       e: PTEnemy;
       yes: Boolean;
   begin

     for i:=0 to 23 do begin

	asm
	  fxs FX_MEMS #$00
	end;

	v:=p[0];

	if v = left_magnet_code then l_magnet:=py;
	if (room > 0) and (v = right_magnet_code) then r_magnet:=py;

	if room = 0 then
	 if v = robot_code then begin
	  robot_x := i shl 3 + 8;// - 1;
	  robot_y := j shl 3;
	 end;

	if v = battery_code then begin
	 battery_x:=i+4;
	 battery_y:=j+1;
	end;


	if (v = enemyrobot_code) or (v = enemyeel_code) then
	 if enemy_cnt < length(enemy) then begin

	   e:=enemy[enemy_cnt];

	   e.x:=i shl 3 + 8;
	   e.y:=j shl 3;
	   e.adx := adx; adx := -adx;

	   if v = enemyeel_code then
	    e.src := src4
	   else
	    e.src := src6;

	   e.frm:=0;

	   e.kind := v;

	   inc(enemy_cnt);
	 end;


	yes:=false;
	case v of
	   5..6: yes:=true;	// robot
	 28..29: yes:=true;

	 19..20: yes:=true;	// enemyrobot
	 41..42: yes:=true;

	     13: yes:=true;	// enemyeel

	end;

	if yes then v:=empty_tile;


	scr[i] := v;

	asm
	    fxs FX_MEMS #$81
	end;

 	x:=i*4;

	m[1+x]:=cmap1[v];
	m[2+x]:=cmap2[v];


	inc(p);
     end;

   end;


begin

 SetPaletteEntry(1, 255,255,255);

 next_level:=false;
 death_Robot:=false;

 l_magnet := $ff;
 r_magnet := $ff;

 battery_x:=0;

 enemy_cnt := 0;

 enemy0.kind:=0;
 enemy1.kind:=0;
 enemy2.kind:=0;
 enemy3.kind:=0;
 enemy4.kind:=0;

 atract:=0;		// disable attract mode

 adx:=1;		// adx default value

 doStatus;


 ofs:=22*24* room + 24;


 if (lvl=0) and (room=6) then inc(robot_x, 8);

 if (lvl=1) and (room=2) then dec(robot_x, 8);
 if (lvl=1) and (room=3) then inc(robot_x, 8);


 m:=pointer(VBXE_WINDOW+4*4);		// color_map pointer, skip row #0

 scr:=pointer(dpeek(88) + 4);		// screen pointer


// okno VBXE $B000..$BFFF jest w tym samym obszarze co pamięć obrazu, oddzielny dostęp CPU/ANTIC
// CPU nie ma jednoczesnego dostępu do mapy kolorów i pamięci obrazu (ANTIC)
//
// musimy włączyć bank VBXE aby zapisać mapę kolorów
// musimy wyłączyć bank VBXE aby zapisać znak w pamięci obrazu

 p:=@map;				// row #0
 row;

 inc(scr, 40);
 inc(m, cmap_width);


 p:=@map + ofs;				// actual level map


 py:=1;

 for j:=0 to 21 do begin		// rows #1..22
  row;

  inc(scr, 40);

  inc(m, cmap_width);

  inc(py);
 end;


 p:=@map + 155*24;			// row #23
 row;

 if room = 0 then robotLifeIcons;

 next_room:=false;
end;

(*-----------------------------------------------------------*)

function empty(a: byte): Boolean;
begin

 Result := (a = id_empty) or (a = id_death) or (a = id_elevator) or (a = id_elevator2);

end;

(*-----------------------------------------------------------*)

function locate(x,y: byte): byte;
var p: PByte register;
begin

	asm
	  fxs FX_MEMS #$00
	end;

  p:=pointer(dpeek(88) + mul_40[y] + x);

  Result:=id[ p[0] ];

end;

(*-----------------------------------------------------------*)

procedure colorRobot;
var a,x,y: byte;
begin

 if death_Robot then begin SetPaletteEntry(1, 70,255,70); exit; end;

 if next_level then begin SetPaletteEntry(1, 200,30,10); exit; end;

 if robot_x and 7 = 0 then begin

   y:=robot_y shr 3;

   x:=robot_x shr 3 + left_magnet_px - 2;

   a:=locate(x, y+1);

   if (a = id_elevator) or (a = id_elevator2) then
    SetPaletteEntry(1, 40,40,40)
   else
    SetPaletteEntry(1, 255,255,255);

 end;


end;

(*-----------------------------------------------------------*)

procedure powerUP;
begin
      tile(empty_tile, battery_x, battery_y);
      tile(empty_tile, battery_x+1, battery_y);

      tile(empty_tile, battery_x, battery_y+1);
      tile(empty_tile, battery_x+1, battery_y+1);

      doPowerFull;
end;

(*-----------------------------------------------------------*)

function hitBox(x,y: byte): Boolean;
begin

 Result:=true;

 if ( byte(robot_x - x + 16 - 1) >= byte(16 + 16 - 1) ) then exit(false);

 if ( byte(robot_y - y + 16 - 1) >= byte(16 + 16 - 1) ) then exit(false);

end;


procedure testEnemy;
var tc: byte;


  procedure update(var spr: TEnemy);
  var a, x,y: byte;
  begin

   if spr.kind <> 0 then begin


    if spr.x and 7 = 0 then begin

    x:=byte(spr.x - 8) shr 3 + 4;
    y:=spr.y shr 3 + 1;

    case spr.kind of

     enemyrobot_code:
	     begin

		if spr.adx = 1 then
		  a := locate(x+2, y)
		else
		  a := locate(x-1, y);

		if not(empty(a)) then
		  spr.adx := -spr.adx
		else begin

		  if spr.adx = 1 then
		    a := locate(x+2, y+2)
		  else
		    a := locate(x-1, y+2);

		  if empty(a) then spr.adx := -spr.adx;

		end;

	     end;


     enemyeel_code:
	     begin

		if spr.adx = 1 then
		  a := locate(x+2, y)
		else
		  a := locate(x-1, y);

		if not(empty(a)) then
		  spr.adx := -spr.adx
		else
		  if (spr.x = 19*8) or (spr.x = 5*8) then spr.adx := -spr.adx;

	     end;

    end;

    end;  // if spr.x and 7


    death_robot := hitBox(spr.x, spr.y);

    if death_robot then exit;


    case spr.kind of
     enemyrobot_code: begin
			if tc = 0 then spr.frm := (spr.frm + spr.adx) and 3;
			SrcBlit(spr.blit, spr.src + spr.frm shl 4);
		      end;

       enemyeel_code: begin
			if tc = 0 then spr.frm := (spr.frm + spr.adx) and 7;
                        SrcBlit(spr.blit, spr.src + spr.frm);
		      end;
    end;


    inc(spr.x, spr.adx);

   end;	// if spr.kind

  end;


begin

  tc:=tick and 3;

  if not death_robot then update(enemy0);
  if not death_robot then update(enemy1);
  if not death_robot then update(enemy2);
  if not death_robot then update(enemy3);
  if not death_robot then update(enemy4);

end;

(*-----------------------------------------------------------*)


procedure testRobot;
var a, b, x, y, y_: byte;
    left, right: Boolean;
begin

 SrcBlit(0, src0);

 y:=robot_y shr 3;


 if (robot_x and 7 = 0) then begin

  x:=robot_x shr 3 + left_magnet_px - 2;

  a := locate(x, y+3);
  b := locate(x+1, y+3);


  if (a = id_death) or (b = id_death) then begin 				// robot failed
    inc(robot_y, 8);

    death_robot:=true;

    exit;
  end;

  if a = id_downbar then begin next_room:=true; dec(robot_y, 20*8); exit end;	// next room


  if (a = id_battery) and (b = id_battery) then powerUP;


  left := (a = id_empty) or (a = id_lava);
  right := (b = id_empty) or (b = id_lava);

  if (a = id_lava) and (y >= 18) then next_level:=true;

  if left and right then begin inc(robot_y, 4); exit end;						// falling down


  y_:=(robot_y-2) shr 3;										// elevator, move up

  elevator:=false;

  a := locate(x, y_+1);
  b := locate(x+1, y_+1);

  if a = b then
   if (a = id_elevator) or (a = id_elevator2) then begin elevator:=true; dec(robot_y, 2) end;


  if elevator then begin

   if (robot_y and 15 <> 0) then exit;

   y:=robot_y shr 3;

   a:=locate(x, y+3);
   b:=locate(x+1, y+3);

   if (a = id_elevator2) and (b = id_elevator2) then exit;

   a:=locate(x, y);
   b:=locate(x+1, y);

   if (a = id_elevator2) and (b = id_elevator2) then exit;


{
   a:=locate(x-1, y+1);
   b:=locate(x-1, y+2);

   left := (not empty(a)) or (not empty(b));

   a:=locate(x+2, y+1);
   b:=locate(x+2, y+2);

   right := (not empty(a)) or (not empty(b));

   if left or right then exit;				// empty tile on both side
}
  end;

 end;


	if (robot_y and 7 <> 0) then exit;


 if robot_x and 7 = 0 then begin

   y:=robot_y shr 3;

   x:=robot_x shr 3 + left_magnet_px - 2;

   a:=locate(x-1, y+2);
   left := empty(a);

   if a = id_battery then powerUP;

   a:=locate(x, y+2);
   if a = id_death then death_Robot:=true;

 end else
  left:=true;

 if left then
  if (l_magnet >= y) and (l_magnet <= y+2) then if robot_x > left_magnet_px*8 then begin SrcBlit(0, src1); dec(robot_x); end;



 if robot_x and 7 = 0 then begin

   y:=robot_y shr 3;

   x:=robot_x shr 3 + left_magnet_px - 2;

   a:=locate(x+2, y+2);
   right := empty(a);

   if a = id_battery then powerUP;

   a:=locate(x+1, y+2);
   if a = id_death then death_Robot:=true;

 end else
  right:=true;

 if right then
  if (r_magnet >= y) and (r_magnet <= y+2) then if robot_x < (right_magnet_px-6)*8 then begin SrcBlit(0, src2); inc(robot_x) end;

end;

(*-----------------------------------------------------------*)

procedure flashBattery;
var p: PByte register;
begin

	asm
	 fxs FX_MEMS #$81
	end;

	p:=cmap_adr[battery_y] + battery_x shl 2 + 1;

	p[0]:=tick;

	p[4]:=tick;

	p[cmap_width]:=tick;

	p[cmap_width + 4]:=tick;


end;

(*-----------------------------------------------------------*)

procedure clrMagnet(a: byte);
begin

 if a = 0 then begin

	if l_magnet > py_limit then exit;

	tile(empty_tile, 5, l_magnet);
	tile(empty_tile, 6, l_magnet);
	tile(empty_tile, 5, l_magnet+1);
	tile(empty_tile, 6, l_magnet+1);

 end else begin

 	if r_magnet > py_limit then exit;

	tile(empty_tile, 25, r_magnet);
	tile(empty_tile, 26, r_magnet);
	tile(empty_tile, 25, r_magnet+1);
	tile(empty_tile, 26, r_magnet+1);

 end;

end;

(*-----------------------------------------------------------*)

procedure setMagnet(a: byte);
begin

 if a = 0 then begin

	if l_magnet > py_limit then exit;

	tile(lmag_tile_code, left_magnet_px, l_magnet);
	tile(lmag_tile_code+1, left_magnet_px+1, l_magnet);
	tile(lmag_tile_code+2, left_magnet_px, l_magnet+1);
	tile(lmag_tile_code+3, left_magnet_px+1, l_magnet+1);

 end else begin

	if r_magnet > py_limit then exit;

	tile(rmag_tile_code, right_magnet_px, r_magnet);
	tile(rmag_tile_code+1, right_magnet_px+1, r_magnet);
	tile(rmag_tile_code+2, right_magnet_px, r_magnet+1);
	tile(rmag_tile_code+3, right_magnet_px+1, r_magnet+1);

 end;

end;

(*-----------------------------------------------------------*)

function anyKey: Boolean; assembler;
asm
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

{$i initvbxe.inc}

(*-----------------------------------------------------------*)

begin

 asm
  lda:cmp:req 20
  lda #0
  sta $10		; irq disable
  sta irqen
 end;

 TextColor($0c);	// color1
 TextBackground($00);	// color2

 InitVBXE;

 lives:=3;
 power:=6;

 robot_x:=48+48;//+48;
 robot_y:=0*8;

 enemy0.blit:=1;
 enemy1.blit:=2;
 enemy2.blit:=3;
 enemy3.blit:=4;
 enemy4.blit:=5;

 enemy[0]:=@enemy0;
 enemy[1]:=@enemy1;
 enemy[2]:=@enemy2;
 enemy[3]:=@enemy3;
 enemy[4]:=@enemy4;

(*-----------------------------------------------------------*)

 titleFnt;

 doStatusPanel;


 lvl:=1;
 level(lvl);

 clock:=0;


// room:= 2+2 + 1;

 newRoom;	// room = 0


(*---------------- VBXE bank = VBXE_BCBADR ------------------*)

// initialize sprites

 IniBlit(0, src0, dst0);	// blit0

 IniBlit(1, src4, dst0);	// blit1
 IniBlit(2, src4, dst0);	// blit2
 IniBlit(3, src4, dst0);	// blit3
 IniBlit(4, src4, dst0);	// blit4
 IniBlit(5, src4, dst0);	// blit5

(*-----------------------------------------------------------*)
(*                       MAIN LOOP                           *)
(*-----------------------------------------------------------*)

 repeat

 pause;

//-------------------- clear sprites ------------------------

						// EraseBlit initialize blt_control
 ClrBlit(0, blt_copy_0 + blt_next);		// mask = $00 ; copy = 0

 ClrBlit(1, blt_copy_0 + blt_next);
 ClrBlit(2, blt_copy_0 + blt_next);
 ClrBlit(3, blt_copy_0 + blt_next);
 ClrBlit(4, blt_copy_0 + blt_next);
 ClrBlit(5, blt_copy_0 + blt_stop);


 RunBCB(Blit0);
 while BlitterBusy do;


//--------------------- set sprites -------------------------

						// MoveBlit modifing blt_control initialize first by EraseBlit


 if (death_robot = false) and (power < 2) and (tick and 7 < 3) then
   DstBlit(0, dst0 + 200*320)			// robot blinks -> move outside the visible screen area
 else
   DstBlit(0, dst0 + robot_y*320 + robot_x);	// mask = $ff ; copy = 1


 if enemy0.kind <> 0 then
   DstBlit(1, dst0 + enemy0.y*320 + enemy0.x)
 else
   DstBlit(1, dst0 + 200*320);

 if enemy1.kind <> 0 then
   DstBlit(2, dst0 + enemy1.y*320 + enemy1.x)
 else
   DstBlit(2, dst0 + 200*320);

 if enemy2.kind <> 0 then
   DstBlit(3, dst0 + enemy2.y*320 + enemy2.x)
 else
   DstBlit(3, dst0 + 200*320);

 if enemy3.kind <> 0 then
   DstBlit(4, dst0 + enemy3.y*320 + enemy3.x)
 else
   DstBlit(4, dst0 + 200*320);

 if enemy4.kind <> 0 then
   DstBlit(5, dst0 + enemy4.y*320 + enemy4.x)
 else
   DstBlit(5, dst0 + 200*320);


 RunBCB(blit0);
 while BlitterBusy do;				// EraseBlit + MoveBlit works together

//-----------------------------------------------------------


	if next_level then begin

	   while anyKey do;

	   inc(lvl); level(lvl);

	   clock:=0;

	   room:=0;
	   lives:=3;
	   power:=6;

	   newRoom;

	end else

	if death_Robot then begin


		if robot_y > 0 then begin

		  dec(robot_y, 2);

		end else begin

		  while anyKey do;

		  death_Robot:=false;

		  dec(lives);

		  if lives = 0 then begin level(lvl); lives:=3 end;

		  clock:=0;

		  room:=0;
		  power:=6;
		  newRoom;

		end;


	end else begin

	  clrMagnet(0); clrMagnet(1);

	  JoyScan;

	  setMagnet(0); setMagnet(1);


	  testRobot;

	  testEnemy;


	  if next_level then wellDoneMessage;

	  if death_robot then endGameMessage;

	  if next_room then begin inc(room); newRoom end;

	  colorRobot;


	  if battery_x > 0 then flashBattery;		// battery blinking

	end;



   inc(tick);


   if lo(clock) >= 3 then begin

     dec(power);

     doStatusPower;
     clock:=0;

     if power=0 then begin
      SetPaletteEntry(1, 70,255,70);
      death_Robot := true;

      endGameMessage;
     end;

   end;


 until false;


 VBXEOff;

end.
