(*

- kazdy level sklada się z 64 tilesow
- 'cmap1', 'cmap2' to mapa kolorów dla 64 tilesow
- 'id' to identyfikator tilesow

*)


uses crt, atari, control, ctm, vsprite, vbxe;

{$define romoff}

{$r robots.rc}

const
	cmap_width = 160;		// color map width 40 * 4 = 160


	left_magnet_code = 32;		// kody tilesow dla level #1
	right_magnet_code = 41;
	robot_code = 23;
	battery_code = 50;


	cmap_adr: array of pointer = [ {$eval 24,"VBXE_WINDOW+:1*cmap_width"} ];

	mul_40: array of word = [ {$eval 24,":1*40"} ];


	lmag_tile: array [0..3] of byte = (32,33,34,35);

	rmag_tile: array [0..3] of byte = (40,41,42,43);


{$i id.inc}			// kody identyfikacji tilesow niezalezne od levelu


var
	cmap1: array [0..63] of byte = (		// color1
	$46, $46, $46, $0e, $98, $46, $0e, $84,
	$36, $56, $36, $56, $36, $56, $82, $82,
	$82, $98, $06, $26, $24, $24, $24, $9e,
	$9e, $98, $98, $0e, $0e, $0a, $0a, $0e,
	$24, $aa, $24, $aa, $82, $98, $98, $c8,
	$aa, $24, $aa, $24, $fd, $fd, $26, $fe,
	$fe, $9a, $38, $38, $38, $38, $98, $98,
	$36, $24, $46, $82, $82, $82, $82, $82
	);


	cmap2: array [0..63] of byte = (		// color2
	$00, $00, $00, $00, $00, $00, $00, $00,
	$0e, $0e, $0e, $0e, $0e, $0e, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00
	);


//	id_empty= 1;
//	id_downbar = 2;
//	id_death = 3;
//	id_lava = 4;
//	id_elevator = 5;
//	id_battery = 6;

	id: array [0..63] of byte = (
	0,0,0,1,0,0,1,0,
	0,0,0,0,0,0,0,1,
	1,1,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,
	0,0,0,0,1,0,0,3,
	0,0,0,0,5,5,0,5,
	5,0,6,6,6,6,0,0,
	0,4,2,0,0,0,0,0
	);
	


	vram: TVBXEMemoryStream;

	robot_x, robot_y, room, lvl: byte;
	battery_x, battery_y: byte;

	next_room, next_level: Boolean;
	death_robot: Boolean;
	elevator: Boolean;

	tick: byte;


(*-----------------------------------------------------------*)

procedure energyFull;
begin




end;


(*-----------------------------------------------------------*)


procedure tile_panel(t: byte; x,y: byte);
var p: PByte register;
begin

	asm
	  fxs FX_MEMS #$00
	end;

	p:=pointer(dpeek(88) + y * 40 + x);

	p[0] := t + panel_ofset;


	asm
	 fxs FX_MEMS #$81
	end;

	p:=cmap_adr[y] + x shl 2 + 1;

	p[0]:=$0e;//cmap1[t];
	p[1]:=$00;//cmap2[t];

end;


procedure doTitle;
var i,j: byte;
begin

 for j:=0 to 23 do
  for i:=0 to 7 do
   tile_panel(panel_map[i+j*8], i+28, j);

end;


(*-----------------------------------------------------------*)


procedure newRoom;
var j, py: byte;
    ofs: word;
    m: Pbyte ;
    p: PByte register;
    scr: PByte register;


   procedure row;
   var v, i, x: byte;
   begin

     for i:=0 to 23 do begin

	asm
	  fxs FX_MEMS #$00
	end;

	v:=p[0];

	if v = left_magnet_code then l_magnet:=py;
	if v = right_magnet_code then r_magnet:=py;

	if room = 0 then
	 if v = robot_code then begin
	  robot_x := i shl 3 + 8;// - 1;
	  robot_y := j shl 3;
	 end;

	if v = battery_code then begin
	 battery_x:=i+4;
	 battery_y:=j+1;
	end;


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

 battery_x:=0;

 l_magnet := $ff;
 r_magnet := $ff;



 ofs:=22*24* room + 24;

 if (lvl=0) and (room=6) then inc(robot_x, 8);


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

 next_room:=false;
end;


(*-----------------------------------------------------------*)


procedure tile(t: byte; x,y: byte);
var p: PByte register;
begin

	asm
	  fxs FX_MEMS #$00
	end;

	p:=pointer(dpeek(88) + y * 40 + x);

	p[0] := t;


	asm
	 fxs FX_MEMS #$81
	end;

	p:=cmap_adr[y] + x shl 2 + 1;

	p[0]:=cmap1[t];
	p[1]:=cmap2[t];

end;


(*-----------------------------------------------------------*)


function empty(a: byte): Boolean;
begin

// Result := (a = empty_tile) or (a = empty2_tile) or (a = empty3_tile) or (a = empty4_tile) or
//	   (a = empty5_tile) or (a = empty6_tile) or (a = death_tile) or
//           (a = elevator_tile) or (a = elevator2_tile) or (a = elevator_tile+1) or (a = elevator2_tile+1);

 Result := (a = id_empty) or (a = id_death) or (a = id_elevator);

end;


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


 if robot_x and 7 = 0 then begin

   y:=robot_y shr 3;

   x:=robot_x shr 3 + left_magnet_px - 2;

   a:=locate(x, y+1);

   if (a = id_elevator) then
    SetPaletteEntry(1, 40,40,40)
   else
    SetPaletteEntry(1, 255,255,255);

 end;


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


  if (a = id_death) or (b = id_death) then begin inc(robot_y, 8); death_robot:=true; exit end;		// robot failed

  if a = id_downbar then begin next_room:=true; dec(robot_y, 20*8); exit end;				// next room


  if (a = id_battery) and (b = id_battery) then begin
   tile(empty_tile, battery_x, battery_y);
   tile(empty_tile, battery_x+1, battery_y);

   tile(empty_tile, battery_x, battery_y+1);
   tile(empty_tile, battery_x+1, battery_y+1);

   energyFull;
  end;


  left := (a = id_empty) or (a = id_lava);
  right := (b = id_empty) or (b = id_lava);

  if (a = id_lava) and (y >= 18) then next_level:=true;

  if left and right then begin inc(robot_y, 4); exit end;						// falling down


  y_:=(robot_y-2) shr 3;										// elevator, move up

  elevator:=false;

  a := locate(x, y_+1);
  b := locate(x+1, y_+1);

  if (a = id_elevator) and (b = id_elevator) then begin elevator:=true; dec(robot_y, 2) end;
//  if (a = elevator2_tile) and (b = elevator2_tile+1) then begin elevator:=true; dec(robot_y, 2) end;


  if elevator then begin

   if (robot_y and 7 <> 0) then exit;

   y:=robot_y shr 3;

   a:=locate(x-1, y+1);
   b:=locate(x-1, y+2);

   left := (not empty(a)) or (not empty(b));

   a:=locate(x+2, y+1);
   b:=locate(x+2, y+2);

   right := (not empty(a)) or (not empty(b));

   if left or right then exit;				// empty tile on both side

  end;

 end;


	if (robot_y and 7 <> 0) then exit;


 if robot_x and 7 = 0 then begin

   y:=robot_y shr 3;

   x:=robot_x shr 3 + left_magnet_px - 2;

   a:=locate(x-1, y+2);
   left := empty(a);

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

	tile(lmag_tile[0], left_magnet_px, l_magnet);
	tile(lmag_tile[1], left_magnet_px+1, l_magnet);
	tile(lmag_tile[2], left_magnet_px, l_magnet+1);
	tile(lmag_tile[3], left_magnet_px+1, l_magnet+1);

 end else begin

	if r_magnet > py_limit then exit;

	tile(rmag_tile[0], right_magnet_px, r_magnet);
	tile(rmag_tile[1], right_magnet_px+1, r_magnet);
	tile(rmag_tile[2], right_magnet_px, r_magnet+1);
	tile(rmag_tile[3], right_magnet_px+1, r_magnet+1);

 end;

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

 InitVBXE;

 robot_x:=128-16;
 robot_y:=0*8;

(*-----------------------------------------------------------*)

 titleFnt;

 doTitle;


 level(0);

 
 room:=3+ 1;

 newRoom;	// room = 0


(*---------------- VBXE bank = VBXE_BCBADR ------------------*)

// initialize sprites

 IniBlit(0, src0, dst0);	// blit0
 IniBlit(1, src1, dst0);	// blit1

(*-----------------------------------------------------------*)
(*                       MAIN LOOP                           *)
(*-----------------------------------------------------------*)

 repeat

 pause;

//-------------------- clear sprites ------------------------

						// EraseBlit initialize blt_control
 ClrBlit(0, blt_copy_0 + blt_next);		// mask = $00 ; copy = 0
 ClrBlit(1, blt_copy_0 + blt_stop);


 RunBCB(Blit0);
 while BlitterBusy do;


//--------------------- set sprites -------------------------

						// MoveBlit modifing blt_control initialize first by EraseBlit
 DstBlit(0, dst0 + robot_y*320+robot_x);	// mask = $ff ; copy = 1
 DstBlit(1, dst0 + 200*320);

 RunBCB(blit0);
 while BlitterBusy do;				// EraseBlit + MoveBlit works together

//-----------------------------------------------------------

 {
	if death_Robot then begin


		if robot_y > 0 then

		  dec(robot_y, 2)

		else begin

		  death_Robot:=false;

		  room:=0;
		  newRoom;

		end;


	end else begin
 }
	  clrMagnet(0);  clrMagnet(1);

	  JoyScan;

	  setMagnet(0); setMagnet(1);

	  testRobot;

	  if next_room then begin inc(room); newRoom end;
	  if next_level then begin inc(lvl); level(lvl); room:=0; newRoom end;

	  if battery_x > 0 then flashBattery;

	  colorRobot;

//	end;


 inc(tick);

 until false;


 VBXEOff;

end.
