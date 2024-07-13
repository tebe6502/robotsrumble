
procedure InitGame;
var i,j: byte;
begin

 sdmctl:=0;
 dmactl:=0;

 pause;

 InitGraph(0);

 pause;


 asm
  lda #0
  sta $10		; irq disable
  sta irqen
 end;


 TextColor($0c);	// color1
 TextBackground($00);	// color2

 poke(756, hi(fnt));


 SetHRes(VBXE.VGAMed);		// 320x240 (VGA)

 SetMapStep(160);


(*------------------- clear VBXE mem ------------------------*)

 vram.position:=VBXE_OVRADR;	// CLEAR VBXE MEM
 vram.size:=320*256;		// VBXE_OVRADR .. VBXE_OVRADR + 320*256
 vram.clear;

(*---------------- VBXE bank = VBXE_BCBADR ------------------*)

// initialize sprites

 IniBlit(0, src_robot, dst0);	// blit0

 IniBlit(1, src_empty, dst0);	// blit1
 IniBlit(2, src_empty, dst0);	// blit2
 IniBlit(3, src_empty, dst0);	// blit3
 IniBlit(4, src_empty, dst0);	// blit4
 IniBlit(5, src_empty, dst0);	// blit5
 IniBlit(6, src_empty, dst0);	// blit6


 for j:=0 to 23 do
  for i:=0 to 39 do tile(empty_tile, i, j);

 for i:=0 to high(mul40) do
  mul40[i] := dpeek(88) + i*40;
 
 for i:=0 to high(mul320) do
  mul320[i] := dst0 + i*320;


 enemy0.blit:=1;
 enemy1.blit:=2;
 enemy2.blit:=3;
 enemy3.blit:=4;
 enemy4.blit:=5;
 enemy5.blit:=6;
 enemy6.blit:=7;

 enemy[0]:=@enemy0;
 enemy[1]:=@enemy1;
 enemy[2]:=@enemy2;
 enemy[3]:=@enemy3;
 enemy[4]:=@enemy4;
 enemy[5]:=@enemy5;
 enemy[6]:=@enemy6;
 
 msx_play := false;

 msx.modul:=pointer(sapr_modul);
 msx.player:=pointer(sapr_player);

 SetIntVec(iVBL, @newVBL);

end;
