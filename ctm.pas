unit ctm;

interface

uses zx0;

// each level has 22 rows, level: 6,5,4,3,2,1,0

const
	fnt = $e000;

	panel_ofset = 80;

var
	map: array [0..24*156-1] of byte;		// 24*156

	cmap1, cmap2, id: array [0..79] of byte;

//	panel_map: array of byte = [ {$bin2csv map\panel.bin} ];		// panel po prawej stronie ekranu
										// dane wygenerowane przez 'panel_update.pas'
	panel_map: array of byte = [
	$2D,$2E,$2E,$2E,$2E,$2E,$2E,$2D,
	$2F,$73,$73,$73,$73,$73,$73,$30,
	$2F,$73,$73,$73,$73,$73,$73,$30,
	$2F,$62,$5F,$52,$5F,$64,$63,$30,
	$2F,$62,$65,$5D,$52,$5C,$55,$30,
	$2F,$73,$73,$73,$73,$73,$73,$30,
	$2F,$73,$73,$73,$73,$73,$73,$30,
	$2F,$60,$5C,$51,$5E,$55,$64,$30,
	$2F,$50,$50,$50,$50,$50,$50,$30,
	$2F,$73,$73,$73,$73,$73,$73,$30,
	$2F,$5C,$66,$5C,$50,$74,$50,$30,
	$2F,$73,$73,$73,$73,$73,$73,$30,
	$2F,$50,$50,$50,$50,$50,$50,$30,
	$2F,$50,$50,$75,$76,$50,$50,$30,
	$2F,$50,$50,$77,$78,$50,$50,$30,
	$2F,$50,$50,$50,$50,$50,$50,$30,
	$2F,$50,$79,$7A,$7B,$79,$50,$30,
	$2F,$50,$79,$7A,$7B,$79,$50,$30,
	$2F,$50,$79,$7A,$7B,$79,$50,$30,
	$2F,$50,$79,$7A,$7B,$79,$50,$30,
	$2F,$50,$79,$7A,$7B,$79,$50,$30,
	$2F,$50,$79,$7A,$7B,$79,$50,$30,
	$2F,$50,$7C,$7D,$7D,$7E,$50,$30,
	$2D,$31,$31,$31,$31,$31,$31,$2D
	];

	
	panel_fnt: array of byte = [ {$bin2csv map\panel_fnt.zx0} ];		// fonty reprezentujace panel, litery, cyfry -> fnt[panel_ofset]...


(*-----------------------------------------------------------*)

	title_map: array of byte = [ {$bin2csv map\title.zx0} ];		// mapa levelu #1 -> map
	title_fnt: array of byte = [ {$bin2csv map\title_fnt.zx0} ];		// fonty 0..63 dla levelu #1 -> fnt[0]...

	title_cmap1: array [0..79] of byte = (		// color1
	$46, $24, $aa, $24, $aa, $0e, $a8, $a7,		// 0..7
	$a7, $56, $36, $0e, $0e, $56, $c8, $82,		// 8..15
	$82, $98, $06, $26, $24, $24, $24, $9e,		// 16..23
	$aa, $24, $aa, $24, $0e, $aa, $ee, $ee,		// 24..31
	$fe, $fe, $0e, $0e, $48, $98, $22, $c8,		// 32..39
	$aa, $24, $aa, $24, $fd, $42, $42, $42,		// 40..47
	$42, $42, $74, $74, $0e, $76, $0e, $0e,		// 48..55
	$26, $a8, $45, $26, $26, $25, $0e, $0e,		// 56..63
	$14, $f2, $f2, $f2, $09, $09, $0e, $82,		// 64..71
	$aa, $26, $94, $00, $00, $00, $00, $00		// 72..
	);
{
	title_cmap2: array [0..79] of byte = (		// color2
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $0e, $0e, $00, $00, $0e, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $0e, $0a, $0e,
	$0a, $0e, $0a, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00
	);
}
(*-----------------------------------------------------------*)

	lvl_1_map: array of byte = [ {$bin2csv map\lvl01.zx0} ];		// mapa levelu #1 -> map
	lvl_1_fnt: array of byte = [ {$bin2csv map\lvl01_fnt.zx0} ];		// fonty 0..63 dla levelu #1 -> fnt[0]...

	lvl_1_cmap1: array [0..79] of byte = (		// color1
	$46, $24, $aa, $24, $aa, $a8, $a8, $a7,		// 0..7
	$a7, $56, $36, $0e, $0e, $56, $c8, $82,		// 8..15
	$82, $98, $06, $26, $24, $24, $24, $9e,		// 16..23
	$aa, $24, $aa, $24, $0e, $0a, $ee, $ee,		// 24..31
	$fe, $fe, $0e, $0e, $48, $98, $22, $c8,		// 32..39
	$aa, $24, $aa, $24, $fd, $42, $42, $42,		// 40..47
	$42, $42, $a8, $0e, $75, $38, $36, $38,		// 48..55
	$36, $38, $36, $f4, $82, $82, $aa, $04,		// 56..63
	$14, $f2, $f2, $f2, $09, $09, $0e, $82,		// 64..71
	$aa, $26, $94, $00, $00, $00, $00, $00
	);

	lvl_1_cmap2: array [0..79] of byte = (		// color2
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $0e, $0e, $00, $00, $0e, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $0e, $0a, $0e,
	$0a, $0e, $0a, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00
	);

//	id_empty= 1;
//	id_downbar = 2;
//	id_death = 3;
//	id_lava = 4;
//	id_elevator = 5;
//	id_battery = 6;

	lvl_1_id: array [0..79] of byte = ( {$bin2csv map/lvl01_id.bin} );

(*-----------------------------------------------------------*)

	lvl_2_map: array of byte = [ {$bin2csv map\lvl02.zx0} ];		// mapa levelu #1 -> map
	lvl_2_fnt: array of byte = [ {$bin2csv map\lvl02_fnt.zx0} ];		// fonty 0..63 dla levelu #1 -> fnt[0]...

	lvl_2_cmap1: array [0..79] of byte = (		// color1
	$46, $24, $aa, $24, $aa, $a8, $a8, $a7,		// 0..7
	$a7, $56, $36, $0e, $0e, $56, $c8, $82,		// 8..15
	$82, $98, $06, $26, $24, $24, $24, $9e,		// 16..23
	$aa, $24, $aa, $24, $0e, $0a, $ee, $ee,		// 24..31
	$fe, $fe, $0e, $0e, $48, $98, $22, $c8,		// 32..39
	$aa, $24, $aa, $24, $fd, $42, $42, $42,		// 40..47
	$42, $42, $a8, $0e, $75, $38, $36, $38,		// 48..55
	$36, $38, $36, $f4, $36, $82, $aa, $38,		// 56..63
	$aa, $9a, $9c, $09, $09, $82, $82, $82,		// 64..71
	$aa, $26, $94, $00, $00, $00, $00, $00
	);

	lvl_2_cmap2: array [0..79] of byte = (		// color2
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $0e, $0e, $00, $00, $0e, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $0e, $0a, $0e,
	$0a, $0e, $0a, $00, $00, $00, $00, $aa,
	$38, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00
	);

	lvl_2_id: array [0..79] of byte = ( {$bin2csv map/lvl02_id.bin} );

(*-----------------------------------------------------------*)

	lvl_3_map: array of byte = [ {$bin2csv map\lvl03.zx0} ];		// mapa levelu #1 -> map
	lvl_3_fnt: array of byte = [ {$bin2csv map\lvl03_fnt.zx0} ];		// fonty 0..63 dla levelu #1 -> fnt[0]...

	lvl_3_cmap1: array [0..79] of byte = (		// color1
	$46, $24, $aa, $24, $aa, $a8, $a8, $a7,		// 0..7
	$a7, $0e, $0e, $0e, $0e, $56, $c8, $82,		// 8..15
	$82, $98, $06, $26, $24, $24, $24, $9e,		// 16..23
	$aa, $24, $aa, $24, $0e, $0a, $ee, $ee,		// 24..31
	$fe, $fe, $0e, $0e, $48, $98, $22, $c8,		// 32..39
	$aa, $24, $aa, $24, $fd, $42, $42, $42,		// 40..47
	$42, $42, $aa, $a8, $a6, $0e, $a6, $0e,		// 48..55
	$36, $38, $36, $38, $36, $38, $82, $83,		// 56..63
	$24, $83, $9c, $26, $d8, $09, $09, $82,		// 64..71
	$24, $a6, $a8, $00, $00, $00, $00, $00
	);

	lvl_3_cmap2: array [0..79] of byte = (		// color2
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $0e, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$0a, $0e, $0a, $0e, $0a, $0e, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00
	);

	lvl_3_id: array [0..79] of byte = ( {$bin2csv map/lvl03_id.bin} );

(*-----------------------------------------------------------*)

	lvl_4_map: array of byte = [ {$bin2csv map\lvl04.zx0} ];		// mapa levelu #1 -> map
	lvl_4_fnt: array of byte = [ {$bin2csv map\lvl04_fnt.zx0} ];		// fonty 0..63 dla levelu #1 -> fnt[0]...

	lvl_4_cmap1: array [0..79] of byte = (		// color1
	$46, $24, $aa, $24, $aa, $a8, $a8, $a7,		// 0..7
	$a7, $0e, $0e, $0e, $0e, $56, $c8, $68,		// 8..15
	$68, $98, $06, $26, $24, $24, $24, $9e,		// 16..23
	$aa, $24, $aa, $24, $0e, $0a, $ee, $ee,		// 24..31
	$fe, $fe, $0e, $0e, $48, $98, $22, $c8,		// 32..39
	$aa, $24, $aa, $24, $fd, $42, $42, $42,		// 40..47
	$42, $42, $aa, $0d, $36, $38, $36, $38,		// 48..55
	$36, $38, $a8, $a8, $82, $a8, $0d, $a5,		// 56..63
	$a7, $53, $09, $09, $0e, $a8, $aa, $e8,		// 64..71
	$e8, $a6, $a8, $00, $00, $a8, $00, $00
	);

	lvl_4_cmap2: array [0..79] of byte = (		// color2
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $0e, $0e, $00, $00, $0e, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $0a, $0e, $0a, $0e,
	$0a, $0e, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00,
	$00, $00, $00, $00, $00, $00, $00, $00
	);

	lvl_4_id: array [0..79] of byte = ( {$bin2csv map/lvl04_id.bin} );

(*-----------------------------------------------------------*)

	function titleFnt: byte;
	procedure level(l: byte);


implementation

uses atari;


function titleFnt: byte;
var a, i,j: byte;
begin

 a:=sdmctl;
 sdmctl:=0;
 dmactl:=0;

 pause;


 unZX0(@panel_fnt, pointer(fnt+panel_ofset*8));


 Result:=a;

end;



procedure level(l: byte);
var a: byte;
begin

 a:=sdmctl;
 sdmctl:=0;
 dmactl:=0;

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

   2: begin
	unZX0(@lvl_3_map, @map);
	unZX0(@lvl_3_fnt, pointer(fnt));

	move(lvl_3_cmap1, cmap1, sizeof(cmap1));
	move(lvl_3_cmap2, cmap2, sizeof(cmap2));
	move(lvl_3_id, id, sizeof(id));
      end;

   3: begin
	unZX0(@lvl_4_map, @map);
	unZX0(@lvl_4_fnt, pointer(fnt));

	move(lvl_4_cmap1, cmap1, sizeof(cmap1));
	move(lvl_4_cmap2, cmap2, sizeof(cmap2));
	move(lvl_4_id, id, sizeof(id));
      end;

 
    9: begin
	unZX0(@title_map, @map);
	unZX0(@title_fnt, pointer(fnt));

	move(title_cmap1, cmap1, sizeof(cmap1));

	fillbyte(cmap2, sizeof(cmap2), 0);
      end;


 end;


 pause;

 sdmctl:=a;

end;


end.

