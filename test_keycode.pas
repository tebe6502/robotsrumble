uses crt;


begin

asm

 lda #0
 sta $10
 sta $d20e

end;

while true do
 writeln(peek($d209));// and %00111111);
 
 
end.