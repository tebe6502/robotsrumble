unit vsprite;

interface

uses crt, vbxe;

const
	bmp = VBXE_OVRADR+320*256;	// adres bitmapy w pamięci VBXE, ladowana przez RESOURCE $R
	bmp2 = bmp + 256*16;

	blt_copy_0	= 0;	// default
	blt_copy_1	= 1;	// src <> 0 -> dst
	blt_copy_2	= 2;	// +
	blt_copy_3	= 3;	// or
	blt_copy_4	= 4;	// and
	blt_copy_5	= 5;	// xor
	blt_copy_6	= 6;
	blt_copy_7	= 7;	// unused
	
	blt_next	= %1000;
	blt_stop	= %0000;

	src_robot = bmp + 0;
	src_robot_right = bmp + 16*2;
	src_robot_left = bmp + 16;

	src_empty = bmp + 16*3;

	src_enemyeel = bmp + 16*4;
	src_enemyrobot = bmp + 16*6;	
	src_enemyfire = bmp + 16*10;
	src_bomb = bmp + 16*12;

	dst0 = VBXE_OVRADR+8*320+24;

var
	blit0: TBCB absolute VBXE_BCBADR+VBXE_WINDOW;		// blity kolejno jeden za drugim
	blit1: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21;
	blit2: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*2;
	blit3: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*3;
	blit4: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*4;
	blit5: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*5;
	blit6: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*6;
	blit7: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*7;

	blit8: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*8;
	blit9: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*9;
	blit10: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*10;
	blit11: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*11;
	blit12: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*12;
	blit13: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*13;
	blit14: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*14;
	blit15: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*15;
	
	blit16: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*16;
	blit17: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*17;
	blit18: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*18;
	blit19: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*19;
	blit20: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*20;
	blit21: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*21;
	blit22: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*22;
	blit23: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*23;

	blit24: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*24;
	blit25: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*25;
	blit26: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*26;
	blit27: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*27;
	blit28: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*28;
	blit29: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*29;
	blit30: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*30;
	blit31: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*31;
	
	blits: array [0..31] of pointer =
	(
	@blit0, @blit1, @blit2, @blit3, @blit4, @blit5, @blit6, @blit7,
	@blit8, @blit9, @blit10, @blit11, @blit12, @blit13, @blit14, @blit15,
	@blit16, @blit17, @blit18, @blit19, @blit20, @blit21, @blit22, @blit23,
	@blit24, @blit25, @blit26, @blit27, @blit28, @blit29, @blit30, @blit31
	);


	procedure IniBlit(spr: byte; src, dst: cardinal);
	procedure ClrBlit(spr: byte; ctr: byte);
	procedure DstBlit(spr: byte; dst: cardinal);
	procedure SrcBlit(spr: byte; src: cardinal);
	procedure SizeBlit(spr: byte; src: word; siz: byte);
	
	
implementation


procedure IniBlit(spr: byte; src, dst: cardinal);
var a: ^TBCB;
begin

	asm
	  fxs FX_MEMS #$80
	end;


 a:=blits[spr];

 fillbyte(a, sizeof(TBCB), 0);

 a.src_adr.byte2:=src shr 16;
 a.src_adr.byte1:=src shr 8;
 a.src_adr.byte0:=src;

 a.dst_adr.byte2:=dst shr 16;
 a.dst_adr.byte1:=dst shr 8;
 a.dst_adr.byte0:=dst;

 a.src_step_x:=1;
 a.src_step_y:=256;

 a.dst_step_x:=1;
 a.dst_step_y:=320;

 a.blt_width:=16-1;
 a.blt_height:=16-1;

// a.blt_and_mask:=0;

 a.blt_zoom:=$00;

// a.blt_control:=ctr;// or 1;

end;


procedure SizeBlit(spr: byte; src: word; siz: byte);
var a: ^TBCB;
begin

	asm
	  fxs FX_MEMS #$80
	end;


 a:=blits[spr];

 a.src_step_y:=src;

 a.blt_width:=byte(siz-1);
 a.blt_height:=siz-1;

end;


procedure ClrBlit(spr: byte; ctr: byte);
var a: ^TBCB;
begin

	asm
	  fxs FX_MEMS #$80
	end;


 a:=blits[spr];

 a.blt_and_mask := $00;

 a.blt_control := ctr;
end;


procedure SrcBlit(spr: byte; src: cardinal);
var a: ^TBCB;
begin

	asm
	  fxs FX_MEMS #$80
	end;


 a:=blits[spr];

 a.src_adr.byte2:=src shr 16;
 a.src_adr.byte1:=src shr 8;
 a.src_adr.byte0:=src;

end;


procedure DstBlit(spr: byte; dst: cardinal);
var a: ^TBCB;
begin

	asm
	  fxs FX_MEMS #$80
	end;


 a:=blits[spr];
 
 a.dst_adr.byte2 := dst shr 16;
 a.dst_adr.byte1 := dst shr 8;
 a.dst_adr.byte0 := dst;

 a.blt_and_mask := $ff;

 inc(a.blt_control);
end;


end.
