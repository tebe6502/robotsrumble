uses crt;

const

	id_empty= 1;
	id_downbar = 2;
	id_death = 3;
	id_lava = 4;
	id_elevator = 5;
	
// level #1
	empty_tile = 3;
	
	empty2_tile = 17;
	empty3_tile = 6;
	empty4_tile = 36;
	
	empty5_tile = 15;
	empty6_tile = 16;
		
	downbar_tile = 58;
	death_tile = 39;

	lava_tile = 57;
	
	battery_tile = 50;	// 50..51 _ 52..53
	
	elevator_tile = 44;	// 44..45
	elevator2_tile = 47;	// 47..48
	

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
 
 for j:=0 to 7 do begin
  for i:=0 to 7 do write(id[i+j*8],',');
  
  writeln;
 end;
 
 
 repeat until keypressed;


end.