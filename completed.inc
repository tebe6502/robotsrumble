
procedure CompletedGame;
var i: byte;
    spr: PTEnemy;
begin
 pause;

 sdmctl:=0;
 dmactl:=0;

 vram.position:=VBXE_OVRADR;	// CLEAR VBXE MEM
 vram.size:=320*256;		// VBXE_OVRADR .. VBXE_OVRADR + 320*256
 vram.clear;
 
 lvl:=7;
 level(7);
 
 cmap1[63] := $45;		// color modification
 cmap1[74] := $aa;
 
 room:=0;
 power:=6;
 
 newRoom;
 
 robot.y:=200;
 
 enemy0.x:=63;
 enemy1.x:=63+17;
 enemy2.x:=63+17*2;
 enemy3.x:=63+17*3;
 enemy4.x:=63+17*4;
 
 enemy0.y:=64;
 enemy1.y:=64-8;
 enemy2.y:=64-8*2;
 enemy3.y:=64-8*3;
 enemy4.y:=64-8*4;
 
 enemy0.kind:=1;
 enemy1.kind:=1;
 enemy2.kind:=1;
 enemy3.kind:=1;
 enemy4.kind:=1;
 enemy5.kind:=0;
 
 enemy0.adx:=-1;
 enemy1.adx:=1;
 enemy2.adx:=1;
 enemy3.adx:=1;
 enemy4.adx:=1;
 
 SrcBlit(1, src_robot);
 SrcBlit(2, src_robot);
 SrcBlit(3, src_robot);
 SrcBlit(4, src_robot);
 SrcBlit(5, src_robot);
 
 SetPaletteEntry(1, 255,255,255);
 
 txt:='WELL DONE';
 TextColor($22);
 doText(11,15);

 txt:='COMPLETED GAME';
 TextColor($fa);
 doText(9,17);

 while anyKey do begin
 
  doSprites;
  
  for i:=0 to 4 do begin
   spr:=enemy[i];
   
   if (spr.y = 64-8*4) or (spr.y = 64) then spr.adx := -spr.adx;

   dec(spr.y, spr.adx);  
  
  end;
 
 end;

end;
