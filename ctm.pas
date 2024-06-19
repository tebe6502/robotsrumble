unit ctm;

interface

uses zx0;

// each level has 22 rows, level: 6,5,4,3,2,1,0

const
	fnt = $e000;
	
	panel_ofset = 76;

var
	map: array [0..24*156-1] of byte;		// 24*156
	
	panel_map: array of byte = [ {$bin2csv map\panel.bin} ];		// panel po prawej stronie ekranu
	panel_fnt: array of byte = [ {$bin2csv map\panel_fnt.zx0} ];		// fonty reprezentujace panel, litery, cyfry -> fnt[76]...
	
	lvl01_map: array of byte = [ {$bin2csv map\lvl01.zx0} ];		// mapa levelu #1 -> map
	lvl01_fnt: array of byte = [ {$bin2csv map\lvl02_fnt.zx0} ];		// fonty 0..63 dla levelu #1 -> fnt[0]...


	procedure titleFnt;
	procedure level(l: byte);


implementation

uses atari;


procedure titleFnt;
var a, i,j: byte;
begin

 a:=sdmctl;
 sdmctl:=0;
 
 pause; 


 unZX0(@panel_fnt, pointer(fnt+76*8));


 pause;
 
 sdmctl:=a;

end;



procedure level(l: byte);
var a: byte;
begin

 a:=sdmctl;
 sdmctl:=0;
 
 pause; 


 unZX0(@lvl01_map, @map);
 unZX0(@lvl01_fnt, pointer(fnt));


 pause;
 
 sdmctl:=a;

end;

{
procedure room(a: byte);
var i: byte;
begin

 for i:=0 to 21 do
  move(map[i*24], pointer(dpeek(88)+i*40), 24);


end;
}


end.

