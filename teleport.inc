
procedure teleportAnimation;
const
	tele_L : array [0..15] of byte = (
	0,
	0,
	%00100000,
	%00100000,
	0,
	0,
	%00100000,
	%00100000,
	
	0,
	0,
	%00100000,
	%00100000,
	0,
	0,
	%00100000,
	%00100000	
	);

	tele_Lx : array [0..15] of byte = (
	0,
	%00000100,
	0,
	0,
	0,
	%00000100,
	0,
	0,

	0,
	%00000100,
	0,
	0,
	0,
	%00000100,
	0,
	0	
	);
	
	tele_R : array [0..15] of byte = (
	0,
	0,
	%00000100,
	%00000100,
	0,
	0,
	%00000100,
	%00000100,
	
	0,
	0,
	%00000100,
	%00000100,
	0,
	0,
	%00000100,
	%00000100	
	);

	tele_Rx : array [0..15] of byte = (
	0,
	%00100000,
	0,
	0,
	0,
	%00100000,
	0,
	0,

	0,
	%00100000,
	0,
	0,
	0,
	%00100000,
	0,
	0	
	);

var
 frm, frm_, frm2, frm2_: word;
 i, y,z: byte;

 p: PByte register;
 q: PByte register;
 
begin

 y := hi(frm) and 7;
 z := hi(frm2) and 7;
 
 p:=pointer(fnt+15*8);		// char #15
 q:=pointer(fnt+16*8);		// char #16
 
 for i:=7 downto 0 do begin
  p[i]:=tele_L[y+i] or tele_Lx[z+i];
  q[i]:=tele_R[y+i] or tele_Rx[z+i];
 end;

 inc(frm, $80);
 dec(frm2,$40);
 
// -------------------------------

 y := hi(frm_) and 7;
 z := hi(frm2_) and 7;
 
 p:=pointer(fnt+71*8);		// char #71
 q:=pointer(fnt+72*8);		// char #72
 
 for i:=7 downto 0 do begin
  p[i]:=tele_L[y+i] or tele_Lx[z+i];
  q[i]:=tele_R[y+i] or tele_Rx[z+i];
 end;

 dec(frm_, $80);
 inc(frm2_,$40);

end;
