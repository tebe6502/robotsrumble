
procedure InitVBXE;
var a, i,j: byte;
begin
{
 if VBXE.GraphResult <> VBXE.grOK then begin
  writeln('VBXE not detected');
  writeln;
  writeln('Press any key to continue');
  
  repeat until keypressed;
  halt;
 end;
}
 a:=sdmctl;
 sdmctl:=0;
 
 pause;
 

// poke(756, hi(fnt));
 
 level(0);

  
 
 SetHRes(VBXE.VGAMed);		// 320x240 (VGA)
 
 SetMapStep(160);


(*------------------- clear VBXE mem ------------------------*)

 vram.position:=VBXE_OVRADR;	// CLEAR VBXE MEM
 vram.size:=320*256;		// VBXE_OVRADR .. VBXE_OVRADR + 320*256
 vram.clear;


 for j:=0 to 23 do
  for i:=0 to 39 do tile(empty_tile, i, j);


 pause;
 
 sdmctl:=a;

end;