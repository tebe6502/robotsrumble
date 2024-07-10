
procedure doTitle;

const
     scrol = '         CODING   TEBE      CONCEPT AND GRAPHICS   MIGUETELO      MUSIC AND SFX   UCTUMI      MADTEAM 2024';

var a, i,j, v: byte;
    w: word;
    p: PByte;
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

 TextColor($af);
 txt:='USE KEYBOARD OR JOY 1';
 doText(5,8);


// scroll

 TextColor($0a);
 TextBackground($00);
 
 for i:=0 to 17 do tile_panel(5+i, 7+i, 5);
 fillbyte(pointer(fnt+5*8), 19*8, 0);
  
 
// stripe animation

 TextColor($00);
 TextBackground($82);
 
 j:=9;
 for i:=0 to 6 do begin
  tile_panel(64,j,1);
  tile_panel(65,j+1,1);

  tile_panel(64,j,3);
  tile_panel(65,j+1,3);

  inc(j, 2);
 end;

 tile_panel(65,13+9,2);

 tile_panel(64,9,2);
 
 
 p:=pointer(fnt+64*8);
 for i:=0 to 15 do p[i]:=$f0;

 
 pause;
 sdmctl:=(normal or enable);
 
 
 a:=0;
 j:=0;
 
 while anyKey do begin


// -----------------------------------
// char 64-65 modyfication -> stripe
// ----------------------------------- 

  case a and 7 of			
   0: begin
       for i:=15 downto 0 do p[i]:=$f0;
       
       inc(j);
       if j > length(scrol) then j:=1;
       
       v:=charCode(byte(scrol[j]));
       
       w := fnt + v shl 3;
       
       for i:=7 downto 0 do poke(fnt+23*8+i, peek(w+i));
       
      end;

   1..4:
	asm
	 .rept 8
	 sec
	 rol $e000+65*8+#
	 rol $e000+64*8+#
	 .endr  
	end;

   else
	asm
	 .rept 8
	 clc
	 rol $e000+65*8+#
	 rol $e000+64*8+#
	 .endr  
	end;
	
   end;


// ----------------------------------- 
// scroll char 5..23
// ----------------------------------- 

  	asm
	 .rept 8
	 asl $e000+23*8+#
	 rol $e000+22*8+#
	 rol $e000+21*8+#
	 rol $e000+20*8+#
	 rol $e000+19*8+#
	 rol $e000+18*8+#
	 rol $e000+17*8+#
	 rol $e000+16*8+#
	 rol $e000+15*8+#
	 rol $e000+14*8+#
	 rol $e000+13*8+#
	 rol $e000+12*8+#
	 rol $e000+11*8+#
	 rol $e000+10*8+#
	 rol $e000+9*8+#
	 rol $e000+8*8+#
	 rol $e000+7*8+#
	 rol $e000+6*8+#
	 rol $e000+5*8+#
	 .endr  
	end;
 
  
   inc(a);
  
 end;

end;
