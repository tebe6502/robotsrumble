uses crt;

var
	audc1, audf1, audc2, audf2, audc3, audf3, audc4, audf4, audctl: array [0..16383] of byte;
	sap: file of byte;
	bin: file;

	sfx: text;

	txt: string;
	ch: byte;

	i, x: integer;

	head: byte;

begin

 assign(sap, 'sfx0.sap'); reset(sap, 1);

{

SAP
AUTHOR
NAME
TYPE
TIME
'empty line'

}

 txt:='';

 i:=0;

 while not eof(sap) do begin
  read(sap, ch);

  if (head < 6) and (ch in [13,10]) then begin

   if ch = 10 then begin writeln(txt); txt:=''; inc(head) end;

  end else
   txt:=txt+chr(ch);


 end;

 close(sap);


 assign(bin, 'sfx.bin'); rewrite(bin, 1);
 blockwrite(bin, txt[1], length(txt));
 close(bin);

 i:=1;
 x:=0;

 while i < length(txt) do begin

  audc1[x] := byte(txt[i]);
  audf1[x] := byte(txt[i+1]);

  audc2[x] := byte(txt[i+2]);
  audf2[x] := byte(txt[i+3]);

  audc3[x] := byte(txt[i+4]);
  audf3[x] := byte(txt[i+5]);

  audc4[x] := byte(txt[i+6]);
  audf4[x] := byte(txt[i+7]);

  audctl[x] := byte(txt[i+8]);

  inc(i, 9);
  inc(x);

 end;

{
 assign(bin, 'sfx_audc4.bin'); rewrite(bin, 1);
 blockwrite(bin, audc4, x);
 close(bin);

 assign(bin, 'sfx_audf4.bin'); rewrite(bin, 1);
 blockwrite(bin, audf4, x);
 close(bin);
}

 assign(sfx, 'sfx0.inc'); rewrite(sfx);

 for i:=0 to x-1 do
   writeln(sfx, #9'$01,$' + hexStr(audc4[i],2) + ',$' + hexStr(audf4[i],2)+ ',');

 writeln(sfx, #9'$00,$ff');

 closefile(sfx);


 repeat until keypressed;

end.