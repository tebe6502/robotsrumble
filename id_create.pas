{

 tworzenie tablicy ID dla zadanego levelu

}

uses crt;

{$i id.inc}


// level #1
	empty_tile = 0;
	
	empty2_tile = 62;
	empty3_tile = 51;
	empty4_tile = 71;
	empty5_tile = 60;
	empty6_tile = 61;
		
	downbar_tile = 49;	// common
	death_tile = 14;

	lava_tile = 38;
	
	battery_tile = 11;	// 11..12
	battery2_tile = 34;	// 34..35
	
	elevator_tile = 30;	// 30..31
	elevator2_tile = 32;	// 32..33
	

var
	id: array [0..63] of byte;

	i,j: byte;


begin

 id[empty_tile] := id_empty;
 id[empty2_tile] := id_empty;
 id[empty3_tile] := id_empty;
 id[empty4_tile] := id_empty;
 id[empty5_tile] := id_empty;
 id[empty6_tile] := id_empty;
 
 id[downbar_tile] := id_downbar;
 
 id[death_tile] := id_death;
 
 id[lava_tile] := id_lava;
 
 id[elevator_tile] := id_elevator;
 id[elevator_tile+1] := id_elevator;
 
 id[elevator2_tile] := id_elevator;
 id[elevator2_tile+1] := id_elevator;
 
 id[battery_tile] := id_battery;
 id[battery_tile+1] := id_battery;
 id[battery2_tile] := id_battery;
 id[battery2_tile+1] := id_battery;
 
 
 for j:=0 to 7 do begin
  for i:=0 to 7 do write(id[i+j*8],',');
  
  writeln;
 end;
 
 
 repeat until keypressed;


end.