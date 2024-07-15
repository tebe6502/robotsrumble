
uses crt, graph, zx0, atari, vbxe;

{$define basicoff}

{$r robots.rc}

const
	bmp = VBXE_OVRADR+320*256;	// adres bitmapy w pamięci VBXE, ladowana przez RESOURCE $R
	bmp2 = bmp + 256*16;


	dlist = $a700;

	scr = $a800;

	cmap = $7000;

	loading: array of byte = [ {$bin2csv rr_image.zx0} ];

	loading_cmp: array of byte = [ {$bin2csv rr_image_cmp.zx0} ];

	cmap_adr: array of pointer = [ {$eval 24,"VBXE_WINDOW+:1*160"} ];

var
	i, x,y: byte;
	w: word;

	p: PByte register;
	q: PByte register;

begin

 if VBXE.GraphResult <> VBXE.grOK then begin
 
  InitGraph(0);
 
  writeln('VBXE not detected');
  writeln;
  writeln('Press any key to continue');

  repeat until keypressed;
  
  asm
	pla
	pla
	rts
  end;
  
 end;

 SetMapStep(160);

 pause;

 sdmctl:=0;
 dmactl:=0;


 unZX0(@loading, pointer(scr));
 unZX0(@loading_cmp, pointer(cmap));


 p:=pointer(dlist);

 p[0]:=$70;
 p[1]:=$70;
 p[2]:=$70;

 p[3]:=$4f;
 p[4]:=lo(scr);
 p[5]:=hi(scr);

 inc(p, 6);
 for i:=0 to 62 do p[i]:=$0f;

 inc(p,63);

 p[0]:=$4f;
 p[1]:=lo(scr+$0800);
 p[2]:=hi(scr+$0800);

 inc(p, 3);
 for i:=0 to 126 do p[i]:=$0f;

 inc(p, 127);

 p[0]:=$41;
 p[1]:=lo(dlist);
 p[2]:=hi(dlist);


 sdlstl:=dlist;


	asm
	 fxs FX_MEMS #$81
	end;

	for y:=0 to 23 do begin

	 p:=cmap_adr[y] + 4*4;

	 q:=pointer(cmap + y*128 + 3*128);

	for x:=0 to 31 do begin

	  p[0]:=q[0];
	  p[1]:=q[1];
	  p[2]:=q[2];
	  p[3]:=q[3];

	  inc(p, 4);
	  inc(q, 4);
	  inc(w, 4);

	end;

	end;

	asm
	 fxs FX_MEMS #$00
	end;

 pause;

 sdmctl:=(narrow or enable);
 dmactl:=sdmctl;

 pause;


 end.
