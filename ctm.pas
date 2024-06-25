unit ctm;

interface

uses zx0;

// each level has 22 rows, level: 6,5,4,3,2,1,0

const
	fnt = $e000;

	panel_ofset = 80;

var
	map: array [0..24*156-1] of byte;		// 24*156

	cmap1, cmap2, id: array [0..72] of byte;

	panel_map: array of byte = [ {$bin2csv map\panel.bin} ];		// panel po prawej stronie ekranu
	panel_fnt: array of byte = [ {$bin2csv map\panel_fnt.zx0} ];		// fonty reprezentujace panel, litery, cyfry -> fnt[panel_ofset]...

(*-----------------------------------------------------------*)

	lvl_1_map: array of byte = [ {$bin2csv map\lvl01.zx0} ];		// mapa levelu #1 -> map
	lvl_1_fnt: array of byte = [ {$bin2csv map\lvl01_fnt.zx0} ];		// fonty 0..63 dla levelu #1 -> fnt[0]...

	lvl_1_cmap1: array [0..72] of byte = (		// color1
	$46, $24, $aa, $24, $aa, $a8, $a8, $a7,		// 0..7
	$a7, $56, $36, $0e, $0e, $56, $c8, $82,		// 8..15
	$82, $98, $06, $26, $24, $24, $24, $9e,		// 16..23
	$aa, $24, $aa, $24, $0e, $0a, $ee, $ee,		// 24..31
	$fe, $fe, $0e, $0e, $82, $98, $98, $c8,		// 32..39
	$aa, $24, $aa, $24, $fd, $42, $42, $42,		// 40..47
	$42, $42, $a8, $0e, $75, $38, $36, $38,		// 48..55
	$36, $38, $36, $f4, $82, $82, $aa, $04,		// 56..63
	$14, $f2, $f2, $f2, $09, $09, $0e, $82,		// 64..71
	$aa
	);

	lvl_1_cmap2: array [0..72] of byte = (		// color2
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $0e, $0e, $00, $00, $0e, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $0e, $0a, $0e,
	$0a, $0e, $0a, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00
	);

//	id_empty= 1;
//	id_downbar = 2;
//	id_death = 3;
//	id_lava = 4;
//	id_elevator = 5;
//	id_battery = 6;

	lvl_1_id: array [0..72] of byte = (
	1,0,0,0,0,0,0,0,
	0,0,0,6,6,0,3,0,
	0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,5,5,
	5,5,6,6,0,0,4,0,
	0,0,0,0,0,0,0,0,
	0,2,0,1,0,0,0,0,
	0,0,0,0,1,1,1,0,
	0,0,0,0,0,0,0,0,
	0
	);

(*-----------------------------------------------------------*)

	lvl_2_map: array of byte = [ {$bin2csv map\lvl01.zx0} ];		// mapa levelu #1 -> map
	lvl_2_fnt: array of byte = [ {$bin2csv map\lvl01_fnt.zx0} ];		// fonty 0..63 dla levelu #1 -> fnt[0]...

	lvl_2_cmap1: array [0..63] of byte = (		// color1
	$46, $46, $46, $0e, $98, $46, $0e, $84,
	$36, $56, $36, $56, $36, $56, $82, $82,
	$82, $98, $06, $26, $24, $24, $24, $9e,
	$9e, $98, $98, $0e, $0e, $0a, $0a, $0e,
	$24, $aa, $24, $aa, $82, $98, $98, $c8,
	$aa, $24, $aa, $24, $fd, $fd, $26, $fe,
	$fe, $9a, $38, $38, $38, $38, $98, $98,
	$36, $24, $46, $82, $82, $82, $82, $82
	);

	lvl_2_cmap2: array [0..63] of byte = (		// color2
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

	lvl_2_id: array [0..63] of byte = (
	0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0
	);

(*-----------------------------------------------------------*)

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


 unZX0(@panel_fnt, pointer(fnt+panel_ofset*8));


 pause;

 sdmctl:=a;

end;



procedure level(l: byte);
var a: byte;
begin

 a:=sdmctl;
 sdmctl:=0;

 pause;


 case l of

   0: begin
	unZX0(@lvl_1_map, @map);
	unZX0(@lvl_1_fnt, pointer(fnt));

	move(lvl_1_cmap1, cmap1, sizeof(cmap1));
	move(lvl_1_cmap2, cmap2, sizeof(cmap2));
	move(lvl_1_id, id, sizeof(id));
      end;

   1: begin
	unZX0(@lvl_2_map, @map);
	unZX0(@lvl_2_fnt, pointer(fnt));

	move(lvl_2_cmap1, cmap1, sizeof(cmap1));
	move(lvl_2_cmap2, cmap2, sizeof(cmap2));
	move(lvl_2_id, id, sizeof(id));
      end;


 end;


 pause;

 sdmctl:=a;

end;


end.

