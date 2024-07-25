uses crt, sysutils;

var
	audc1, audf1, audc2, audf2, audc3, audf3, audc4, audf4, audctl, audc, audf: array [0..16383] of byte;
	sap: file of byte;
	bin: file;

	sfx: text;

	txt: string;
	ch: byte;

	i, x: integer;

	head: byte;
{
; Command:
;
;1. TIME,AUDF,AUDC          ; graj TIME ilość ramek, zapisz rejestry AUDF, AUDC
;2. REPF,TIME,COUNT,AUDC    ; powtórz COUNT razy: graj TIME ilosc ramek, zainicjuj AUDC, wpisuj AUDF COUNT razy
;3. REPC,TIME,COUNT,AUDF    ; powtórz COUNT razy: graj TIME ilosc ramek, zainicjuj AUDF, wpisuj AUDC COUNT razy
;4. LOOP                    ; powtórz ten sam dźwięk od komendy na pozycji loop
;5. RTS                     ; koniec opisu dźwięku
;6. JSR nnnnn               ; wywołaj SFX nr. nn i po jego zakończeniu wróć kontynuuj odtwarzanie obecnego
;7. JMP nnnnn               ; skocz do SFX nr.
;
; Code:
;
; TIME = $01..$0f
; REPF = $c0
; REPC = $80
; LOOP = $00,NUM
; RTS  = $00,$ff
; JSR  = $a0,SFX
; JMP  = $e0,SFX
}


procedure reg(fn: string);
begin

 assign(sap, fn); reset(sap, 1);

{

SAP
AUTHOR
NAME
TYPE
TIME
'empty line'

}

 txt:='';

 head:=0;
 i:=0;

 while not eof(sap) do begin
  read(sap, ch);

  if (head < 6) and (ch in [13,10]) then begin

   if ch = 10 then begin writeln(txt); txt:=''; inc(head) end;

  end else
   txt:=txt+chr(ch);


 end;

 close(sap);


 i:=1;
 x:=0;

 while i < length(txt) do begin

  audf1[x] := byte(txt[i]);
  audc1[x] := byte(txt[i+1]);

  audf2[x] := byte(txt[i+2]);
  audc2[x] := byte(txt[i+3]);

  audf3[x] := byte(txt[i+4]);
  audc3[x] := byte(txt[i+5]);

  audf4[x] := byte(txt[i+6]);
  audc4[x] := byte(txt[i+7]);

  audctl[x] := byte(txt[i+8]);

  inc(i, 9);
  inc(x);

 end;


 fn:=ChangeFileExt(fn, '.inc');

 assign(sfx, fn); rewrite(sfx);


 for i:=0 to x-1 do begin

   if i mod 8=0 then begin writeln(sfx); write(sfx, #9) end;

   write( sfx, '$' + hexStr(audf4[i],2) + ',$' + hexStr(audc4[i],2) + ',' );

 end;

 writeln(sfx,'255,255');


 closefile(sfx);


end;


{
procedure toSFX(len: integer);
var rpt,i, j, l: integer;
begin

 assign(sfx, 'sfx1.inc'); rewrite(sfx);

 i:=0;
 l:=0;

 while i < len do begin

   rpt:=0;

   while audf4[i] = audf4[i+1] do begin
     audf[rpt]:=audf4[i];
     audc[rpt]:=audc4[i];

     audf[rpt+1]:=audf4[i+1];
     audc[rpt+1]:=audc4[i+1];

     inc(rpt);
     inc(i);

   end;


   if rpt = 0 then begin
    writeln(sfx, #9'$01,$' + hexStr(audc4[i],2) + ',$' + hexStr(audf4[i],2)+ ',');
    inc(i);

    inc(l, 3);
   end else begin

    writeln(sfx, #9'$c0,$01,$' + hexStr(rpt+1, 2) + ',$' + hexStr(audf[0],2) + ',');

    inc(l, 4+rpt+1);

    write(sfx, #9);
    for j:=0 to rpt do write(sfx, '$' + hexStr(audc[j], 2) + ',');
    writeln(sfx);

   end;

 end;

 writeln(sfx, #9'$00,$ff');

 inc(l,2);

 closefile(sfx);

 writeln(l);

end;
}


begin

 reg('sfx0.sap');
 reg('sfx1.sap');
 reg('sfx2.sap');
 reg('sfx3.sap');
 reg('sfx4.sap');
 reg('sfx5.sap');


 repeat until keypressed;

end.