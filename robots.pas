
// dlaczego dla makra  $define nie mozna wstawic kodu asm
// nie moze byc dostepu do tablicy 'enemy[] od record'  jako enemy.x itd.

{
; optimize OK (robots.pas), line = 426

	lda J
	sta :STACKORIGIN+9
	lda #$00
	asl :STACKORIGIN+9
	rol @
	asl :STACKORIGIN+9
	asl :STACKORIGIN+9
	ldy #E.Y-DATAORIGIN
	lda :STACKORIGIN+9
	sta (:bp2),y
}

(*

Robots Rumble

https://www.file-hunter.com/MSXdev/index.php?id=roborumble

- kazdy level sklada się z 80 tilesow (80 znakow)
- 'cmap1', 'cmap2' to mapa kolorów dla tilesow
- 'id' to identyfikator tilesow

kazda lokacja przegladana jest w poszukiwaniu tilesow reprezentujacych
prawy/lewy magnes, baterie etc.

*)


uses crt, atari, joystick, control, ctm, vsprite, vbxe;

{$define romoff}

{$r robots.rc}

type
	TPos = record
		x,y: byte;
	       end;

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

	brick_tile = 9;

	left_magnet_code = 1;		// wspolne kody tilesow
	right_magnet_code = 24;
	robot_code = 5;
	battery_code = 11;

	box_corner = 45;
	box_top = 46;
	box_left = 47;
	box_right = 48;
	box_bottom = 49;

	teleport_in_code = 70;
	teleport_out_code = 15;

	enemyrobot_code = 19;
	enemyeel_code = 13;
	enemyfire_code = 17;
	bomb_code = 21;

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

	robot, battery, teleport: TPos;

	room, lvl, lives, power, enemy_cnt: byte;

	next_room, next_level: Boolean;
	death_robot: Boolean;
	elevator: Boolean;

	tick: byte;

	clock: word absolute $13;

	txt: TString;

	enemy0, enemy1, enemy2, enemy3, enemy4, enemy5, enemy6: TEnemy;

	enemy: array [0..6] of PTEnemy;


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

procedure restoreBlit;
begin

 SrcBlit(0, src_robot);

 enemy0.kind:=0;
 enemy1.kind:=0;
 enemy2.kind:=0;
 enemy3.kind:=0;
 enemy4.kind:=0;
 enemy5.kind:=0;
 enemy6.kind:=0;

end;

(*-----------------------------------------------------------*)

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

 txt:='';

 TextColor($0e);

 v:=6 - room;

 if lvl < 5 then str(v, txt);
 doText(32, 10);	// room

 if lvl < 5 then str(lives, txt);
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

	x:=byte(robot.x-8) shr 3;
	y:=robot.y shr 3;

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
	  robot.x := i shl 3 + 8;
	  robot.y := j shl 3;
	 end;


	case v of
	  battery_code:
		begin
		  battery.x := i+4;
		  battery.y := j+1;
		end;

	  teleport_out_code:
		begin
		  teleport.x := i shl 3 + 8;
		  teleport.y := j shl 3 - 8;
		end;
	end;



	if (v = enemyrobot_code) or (v = enemyeel_code) or (v = enemyfire_code) or (v = bomb_code) then
	 if enemy_cnt < length(enemy) then begin

	   e:=enemy[enemy_cnt];

	   e.x := i shl 3 + 8;
	   e.y := j shl 3;


	   case v of
	      enemyeel_code: begin
				e.src := src_enemyeel;
				e.adx := adx;

				if (lvl = 2) and (j > 12) then
				 adx := 0
				else
				 adx := -adx;

			     end;

	     enemyfire_code: begin e.src := src_enemyfire; e.adx := adx end;

	    enemyrobot_code: begin e.src := src_enemyrobot; e.adx := adx; adx := -adx end;

	          bomb_code: begin e.src := src_bomb; e.adx:=0 end;
	   end;


	   e.frm:=0;

	   e.kind := v;

	   inc(enemy_cnt);
	 end;


	yes:=false;
	case v of
	 5..6, 28..29: if lvl < 5 then yes:=true;	// robot

	 19..20, 41..42: yes:=true;	// enemyrobot

	 21..22, 43..44: yes:=true;	// bomb

	 17..18, 39..40: yes:=true;	// enemyfire

	     13: yes:=true;		// enemyeel
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

 pause;

 sdmctl:=0;
 dmactl:=0;

 vram.position:=VBXE_OVRADR;	// CLEAR VBXE MEM
 vram.size:=320*256;		// VBXE_OVRADR .. VBXE_OVRADR + 320*256
 vram.clear;

 SetPaletteEntry(1, 255,255,255);

 next_level:=false;
 death_Robot:=false;

 l_magnet := $ff;
 r_magnet := $ff;

 battery.x:=0;

 enemy_cnt := 0;

 enemy0.kind:=0;
 enemy1.kind:=0;
 enemy2.kind:=0;
 enemy3.kind:=0;
 enemy4.kind:=0;
 enemy5.kind:=0;
 enemy6.kind:=0;

 atract:=0;		// disable attract mode

 adx:=1;		// adx default value

 doStatus;


 ofs:=22*24* room + 24;

 if (lvl = 0) and (room=2) then inc(robot.x, 16);
 if (lvl = 0) and (room=6) then inc(robot.x, 8);

 if (lvl = 1) and (room=2) then dec(robot.x, 8);
 if (lvl = 1) and (room=3) then inc(robot.x, 8);


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


 if lvl < 5 then
  p:=@map + 155*24;			// end of map -> row #23

 row;

 if (room = 0) and (lvl < 5) then robotLifeIcons;

 next_room:=false;
 
 sdmctl:=(normal or enable);
end;


(*-----------------------------------------------------------*)

procedure CompletedGame;
begin
 pause;

 sdmctl:=0;
 dmactl:=0;

 vram.position:=VBXE_OVRADR;	// CLEAR VBXE MEM
 vram.size:=320*256;		// VBXE_OVRADR .. VBXE_OVRADR + 320*256
 vram.clear;
 
// lvl:=7;
 level(7);
 room:=0;
 
 power:=6;
 
 newRoom;


 while anyKey do;

end;

(*-----------------------------------------------------------*)

procedure doTitle;
var a, i,j, v: byte;
begin

 level(8);	// panel

 lvl:=9;
 level(lvl);

 room:=0;
 newRoom;


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


 for power:=5 downto 0 do doStatusPower;

 TextColor($36);
 txt:='ROBOTS';
 doText(10,2);

 TextColor($7a);
 txt:='RUMBLE';
 doText(16,2);

 sdmctl:=(normal or enable);
 
 while anyKey do;

end;

(*-----------------------------------------------------------*)

function empty(a: byte): Boolean;
begin

 case a of
  id_empty, id_death, id_elevator..id_teleport_out: Result := true;
 else
  Result := false
 end;

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

procedure floor_fall(x,y: byte);
var a, b: byte;
begin

   tile(empty_tile, x, y);
   tile(empty_tile, x+1, y);

end;

(*-----------------------------------------------------------*)

procedure move_brick(x,y: byte; adx: shortint);
var a, b: byte;
begin

  if adx < 0 then begin		// move left

   tile(brick_tile, x-1, y);
   tile(brick_tile+1, x, y);
   tile(empty_tile, x+1, y);

   dec(x);

  end else begin		// move right

   tile(empty_tile, x, y);
   tile(brick_tile, x+1, y);
   tile(brick_tile+1, x+2, y);

   inc(x);

  end;


  a:=locate(x, y+1);
  b:=locate(x+1, y+1);

  if empty(a) and empty(b) then begin

   tile(empty_tile, x, y);
   tile(empty_tile, x+1, y);

   tile(brick_tile, x, y+1);
   tile(brick_tile+1, x+1, y+1);

  end;


end;

(*-----------------------------------------------------------*)

procedure colorRobot;
var a,x,y: byte;
begin

 if death_Robot then begin SetPaletteEntry(1, 70,255,70); exit; end;

 if next_level then begin SetPaletteEntry(1, 200,30,10); exit; end;

 if robot.x and 7 = 0 then begin

   y:=robot.y shr 3;

   x:=robot.x shr 3 + left_magnet_px - 2;

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
      tile(empty_tile, battery.x, battery.y);
      tile(empty_tile, battery.x+1, battery.y);

      tile(empty_tile, battery.x, battery.y+1);
      tile(empty_tile, battery.x+1, battery.y+1);

      doPowerFull;
end;

(*-----------------------------------------------------------*)

function hitBox(x,y: byte): Boolean;
begin

 Result:=true;

 if ( byte(robot.x+1 - x+1 + 14-1 ) >= byte(14 + 14 - 1) ) then exit(false);
 if ( byte(robot.y+1 - y+1 + 14-1 ) >= byte(14 + 14 - 1) ) then exit(false);

end;

(*-----------------------------------------------------------*)

function testBomb(x,y: byte): shortint;
var i: byte;
    e: PTEnemy;


  function hitEnemy: Boolean;
  begin

    Result:=true;

    if ( byte(e.x+1 - x+1 + 14-1 ) >= byte(14 + 14 - 1) ) then exit(false);
    if ( byte(e.y+1 - y+1 + 14-1 ) >= byte(14 + 14 - 1) ) then exit(false);

  end;


begin

 Result:=-1;

 for i:=High(enemy) downto 0 do begin

  e:=enemy[i];

  if (e.kind <> 0) and (e.kind <> bomb_code) then
    if hitEnemy then exit(i);

 end;

end;

(*-----------------------------------------------------------*)

procedure testEnemy;
var tc: byte;


  procedure update(var spr: TEnemy);
  var a,b, x,y: byte;
      h: shortint;
      yes: Boolean;
  begin

   if spr.kind <> 0 then begin


    if spr.x and 7 = 0 then begin

    x:=byte(spr.x - 8) shr 3 + 4;
    y:=spr.y shr 3 + 1;

    case spr.kind of

     enemyrobot_code, enemyfire_code:
	     begin

		if spr.adx = 1 then begin
		  a := locate(x+2, y);
		  b := locate(x+2, y+1);
		end else begin
		  a := locate(x-1, y);
		  b := locate(x-1, y+1);
		end;

		if (empty(a) = false) or (empty(b) = false) then
		  spr.adx := -spr.adx
		else
		  if (spr.x = 19*8) or (spr.x = 5*8) then spr.adx := -spr.adx;

	     end;


     enemyeel_code:
	     begin

		if spr.adx = 1 then
		  a := locate(x+2, y)
		else
		  a := locate(x-1, y);

		if not empty(a) then
		  spr.adx := -spr.adx
		else
		  if (spr.x = 19*8) or (spr.x = 5*8) then spr.adx := -spr.adx;

	     end;


         bomb_code:
	     begin

		a := locate(x, y+2);
		b := locate(x+1, y+2);

		if empty(a) and empty(b) then begin
		 inc(spr.y, 4);
		 inc(spr.adx);		// bomb falling down

		 if spr.y and 7 = 0 then begin

		   h := testBomb(spr.x, spr.y);

		   if h >=0 then begin	// bomb hit enemy
		     spr.kind:=0; enemy[h].kind:=0;
		   end;

		 end;

		end else begin

		 if spr.adx > 0 then spr.kind := 0;//explode_code;

		 spr.adx := 0;		// bomb stand

		end;

	     end;

    end;

    end;  // if spr.x and 7


    if spr.kind = bomb_code then begin		// bomb shift ->

     if spr.adx = 0 then begin

       yes := hitBox(spr.x + 2, spr.y);		// +4 robot przylega do bomby ; +2 -> 4px odstep od bomby

       if yes then
        if (robot.x < spr.x) then
           inc(spr.x)
         else
           dec(spr.x);

     end;

    end else
     death_robot := hitBox(spr.x, spr.y);


    if death_robot then exit;


    case spr.kind of
     enemyrobot_code: begin
			if tc = 0 then spr.frm := (spr.frm + spr.adx) and 3;
			SrcBlit(spr.blit, spr.src + spr.frm shl 4);

			inc(spr.x, spr.adx);
		      end;

       enemyeel_code: begin
			if tc = 0 then spr.frm := (spr.frm + spr.adx) and 7;
                        SrcBlit(spr.blit, spr.src + spr.frm);

			inc(spr.x, spr.adx);
		      end;

      enemyfire_code: begin
			if tc = 0 then spr.frm := (spr.frm + rnd) and 1;
                        SrcBlit(spr.blit, spr.src + spr.frm shl 4);

			inc(spr.x, spr.adx);
		      end;

           bomb_code: begin
			if tc = 0 then spr.frm := (spr.frm + 1) and 1;
                        SrcBlit(spr.blit, spr.src + spr.frm shl 4);
		      end;
    end;

   end;	// if spr.kind

  end;


begin

  tc:=tick and 3;

  if not death_robot then update(enemy0);
  if not death_robot then update(enemy1);
  if not death_robot then update(enemy2);
  if not death_robot then update(enemy3);
  if not death_robot then update(enemy4);
  if not death_robot then update(enemy5);
  if not death_robot then update(enemy6);

end;

(*-----------------------------------------------------------*)

procedure testRobot;
var a,b,c, x, y, y_, v: byte;
    left, right: Boolean;
    p: PByte;


  function magnet_field(yp: byte): Boolean;
  begin
    Result := (yp >= y) and (yp <= byte(y+2));
  end;


begin

 SrcBlit(0, src_robot);

 y:=robot.y shr 3;


 if (robot.x and 7 = 0) then begin

  x:=robot.x shr 3 + left_magnet_px - 2;



  a:=locate(x, y+2);
  b:=locate(x+1, y+2);

  if (a=b) and (a = id_teleport_in) then begin
   SrcBlit(0, src_robot);
   robot.x := teleport.x;
   robot.y := teleport.y;

   exit;
  end;




  a := locate(x, y+3);
  b := locate(x+1, y+3);


  if (a = b) and (a = id_floor) then begin
   floor_fall(x,y+3);

   a:=id_empty;
   b:=id_empty;
  end;


  if (a = id_death) or (b = id_death) then begin 				// robot failed
    inc(robot.y, 8);

    death_robot:=true;

    exit;
  end;

  if a = id_downbar then begin next_room:=true; dec(robot.y, 20*8); exit end;	// next room


  if (a = id_battery) and (b = id_battery) then powerUP;


  left := (a = id_empty) or (a = id_lava);
  right := (b = id_empty) or (b = id_lava);

  if (a = id_lava) and (y >= 18) then next_level:=true;

  if left and right then begin inc(robot.y, 4); exit end;						// falling down


  y_:=byte(robot.y-2) shr 3;										// elevator, move up

  elevator:=false;

  a := locate(x, y_+1);
  b := locate(x+1, y_+1);

  if a = b then
   if (a = id_elevator) or (a = id_elevator2) then begin elevator:=true; dec(robot.y, 2) end;


  if elevator then begin

   a:=locate(x, y+3);
   b:=locate(x+1, y+3);

   if (a = id_elevator2) and (b = id_elevator2) then exit;

   a:=locate(x, y+4);
   b:=locate(x+1, y+4);

   if (a = id_elevator2) and (b = id_elevator2) then exit;


   a:=locate(x, y);
   b:=locate(x+1, y);

   if (a = id_elevator2) and (b = id_elevator2) then exit;

  end;

 end;


	if (robot.y and 7 <> 0) then exit;


 if robot.x and 7 = 0 then begin			// robot move left

   x:=robot.x shr 3 + left_magnet_px - 2;

   b:=locate(x-1, y+1);
   a:=locate(x-1, y+2);
   left := empty(a) and empty(b);

   if left and magnet_field(l_magnet) then begin

     if (a = id_battery) or (b = id_battery) then powerUP;

     if a = id_brick_right then move_brick(x-2, y+2, -1);

   end;

   a:=locate(x, y+2);
   if a = id_death then death_Robot:=true;

 end else
  left:=true;



 if robot.x and 7 = 0 then begin			// robot move right

   x:=robot.x shr 3 + left_magnet_px - 2;

   b:=locate(x+2, y+1);
   a:=locate(x+2, y+2);
   right := empty(a) and empty(b);

   if right and magnet_field(r_magnet) then begin

     if (a = id_battery) or (b = id_battery) then powerUP;

     if a = id_brick_left then move_brick(x+2,y+2, 1);

   end;

   a:=locate(x+1, y+2);
   if a = id_death then death_Robot:=true;

 end else
  right:=true;



 v:=0;

 if left then
  if magnet_field(l_magnet) then if robot.x > left_magnet_px*8 then dec(v);

 if right then
  if magnet_field(r_magnet) then if robot.x < (right_magnet_px-6)*8 then inc(v);


 case v of
    0: SrcBlit(0, src_robot);		// 0
    1: SrcBlit(0, src_robot_right);	// +1
  255: SrcBlit(0, src_robot_left);	// -1
 end;

 inc(robot.x, v);

end;

(*-----------------------------------------------------------*)

procedure flashBattery;
var p: PByte register;
begin

	asm
	 fxs FX_MEMS #$81
	end;

	p:=cmap_adr[battery.y] + battery.x shl 2 + 1;

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

{$i initgame.inc}

(*-----------------------------------------------------------*)

begin

 InitGame;

(*-----------------------------------------------------------*)

 while true do begin

  doTitle;

  CompletedGame;

  lvl:=0;
  clock:=0;
 
  lives:=3;
  power:=6;

  level(lvl);

// room:= 6;//+2 + 1;
  room:=0;
 
  newRoom;
  

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
 ClrBlit(5, blt_copy_0 + blt_next);
 ClrBlit(6, blt_copy_0 + blt_stop);


 RunBCB(Blit0);
 while BlitterBusy do;


//--------------------- set sprites -------------------------

						// MoveBlit modifing blt_control initialize first by EraseBlit


 if (death_robot = false) and (power < 2) and (tick and 7 < 3) then
   DstBlit(0, dst0 + 200*320)			// robot blinks -> move outside the visible screen area
 else
   DstBlit(0, dst0 + robot.y*320 + robot.x);	// mask = $ff ; copy = 1


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

 if enemy5.kind <> 0 then
   DstBlit(6, dst0 + enemy5.y*320 + enemy5.x)
 else
   DstBlit(6, dst0 + 200*320);

 if enemy6.kind <> 0 then
   DstBlit(7, dst0 + enemy6.y*320 + enemy6.x)
 else
   DstBlit(7, dst0 + 200*320);


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


		if robot.y > 0 then begin

		  dec(robot.y, 2);

		end else begin

		  while anyKey do;

		  death_Robot:=false;

		  dec(lives);

		  if lives = 0 then Break;//begin level(lvl); lives:=3 end;

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


	  if next_level then
	   if lvl = 3 then 
	    CompletedGame
	   else	   
	    wellDoneMessage;
	    

	  if death_robot then endGameMessage;

	  if next_room then begin inc(room); newRoom end;

	  colorRobot;


	  if battery.x > 0 then flashBattery;		// battery blinking

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

end;

 VBXEOff;

end.
