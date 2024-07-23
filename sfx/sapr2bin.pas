uses crt;

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



begin

 assign(sap, 'sfx1.sap'); reset(sap, 1);

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

{
 assign(bin, 'sfx.bin'); rewrite(bin, 1);
 blockwrite(bin, txt[1], length(txt));
 close(bin);
}

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




 assign(sfx, 'sfx.inc'); rewrite(sfx);

 for i:=0 to x-1 do
   writeln(sfx, #9'$01,$' + hexStr(audc4[i],2) + ',$' + hexStr(audf4[i],2)+ ',');

 writeln(sfx, #9'$00,$ff');

 closefile(sfx);



 toSFX(x);


 repeat until keypressed;

end.