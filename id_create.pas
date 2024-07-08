{

 tworzenie tablicy ID dla zadanego levelu

}

uses crt;

{$i id.inc}

var
	id: array [0..79] of byte;

	i,j: byte;

	f: file;

(*---------------------------------------------------*)

procedure level0;		// level #1
const
	empty_tile = 0;

	empty2_tile = 62;
	empty3_tile = 51;
	empty4_tile = 71;

//	empty5_tile = 60;
//	empty6_tile = 61;

	downbar_tile = 49;	// common
	death_tile = 14;

	lava_tile = 38;

	battery_tile = 11;	// 11..12
	battery2_tile = 34;	// 34..35

	elevator_tile = 30;	// 30..31
	elevator2_tile = 32;	// 32..33
begin

 fillbyte(id, sizeof(id), 0);

 id[empty_tile] := id_empty;
 id[empty2_tile] := id_empty;
 id[empty3_tile] := id_empty;
 id[empty4_tile] := id_empty;

// id[empty5_tile] := id_empty;
// id[empty6_tile] := id_empty;

 id[downbar_tile] := id_downbar;

 id[death_tile] := id_death;

 id[lava_tile] := id_lava;

 id[elevator_tile] := id_elevator;
 id[elevator_tile+1] := id_elevator;

 id[elevator2_tile] := id_elevator2;
 id[elevator2_tile+1] := id_elevator2;

 id[battery_tile] := id_battery;
 id[battery_tile+1] := id_battery;
 id[battery2_tile] := id_battery;
 id[battery2_tile+1] := id_battery;

 assign(f,'map/lvl01_id.bin'); rewrite(f, 1);
 blockwrite(f, id, sizeof(id));
 close(f);
{
 for j:=0 to 9 do begin
  for i:=0 to 7 do write(id[i+j*8],',');

  writeln;
 end;
}
end;

(*---------------------------------------------------*)

procedure level1;		// level #2
const
	empty_tile = 0;

	empty1_tile = 50;	// 50..52

	empty2_tile = 69;
	empty3_tile = 70;
	empty4_tile = 71;

	empty5_tile = 65;
	empty6_tile = 66;
	empty7_tile = 73;

	downbar_tile = 49;	// common
	death_tile = 14;

	lava_tile = 38;

	battery_tile = 11;	// 11..12
	battery2_tile = 34;	// 34..35

	elevator_tile = 30;	// 30..31
	elevator2_tile = 32;	// 32..33
begin

 fillbyte(id, sizeof(id), 0);

 id[empty_tile] := id_empty;

 id[empty1_tile] := id_empty;
 id[empty1_tile+1] := id_empty;
 id[empty1_tile+2] := id_empty;

 id[empty2_tile] := id_empty;
 id[empty2_tile+1] := id_empty;
 id[empty2_tile+2] := id_empty;
 id[empty2_tile+3] := id_empty;
 id[empty2_tile+4] := id_empty;

 id[empty5_tile] := id_empty;
 id[empty6_tile] := id_empty;
 id[empty7_tile] := id_empty;

 id[downbar_tile] := id_downbar;

 id[death_tile] := id_death;

 id[lava_tile] := id_lava;

 id[elevator_tile] := id_elevator;
 id[elevator_tile+1] := id_elevator;

 id[elevator2_tile] := id_elevator2;
 id[elevator2_tile+1] := id_elevator2;

 id[battery_tile] := id_battery;
 id[battery_tile+1] := id_battery;
 id[battery2_tile] := id_battery;
 id[battery2_tile+1] := id_battery;

 assign(f,'map/lvl02_id.bin'); rewrite(f, 1);
 blockwrite(f, id, sizeof(id));
 close(f);
{
 for j:=0 to 9 do begin
  for i:=0 to 7 do write(id[i+j*8],',');

  writeln;
 end;
}
end;

(*---------------------------------------------------*)

procedure level2;		// level #3
const
	empty_tile = 0;

	empty1_tile = 50;	// 50..55

	empty2_tile = 62;

	empty3_tile = 71;

	brick_tile = 9;		// 9..10

	downbar_tile = 49;	// common
	death_tile = 14;

	lava_tile = 38;

	battery_tile = 11;	// 11..12
	battery2_tile = 34;	// 34..35

	elevator_tile = 30;	// 30..31
	elevator2_tile = 32;	// 32..33
begin

 fillbyte(id, sizeof(id), 0);

 id[empty_tile] := id_empty;

 id[empty1_tile] := id_empty;
 id[empty1_tile+1] := id_empty;
 id[empty1_tile+2] := id_empty;
 id[empty1_tile+3] := id_empty;
 id[empty1_tile+4] := id_empty;
 id[empty1_tile+5] := id_empty;

 id[empty2_tile] := id_empty;

 id[empty3_tile] := id_empty;

 id[brick_tile]	:= id_brick_left;
 id[brick_tile+1] := id_brick_right;

 id[downbar_tile] := id_downbar;

 id[death_tile] := id_death;

 id[lava_tile] := id_lava;

 id[elevator_tile] := id_elevator;
 id[elevator_tile+1] := id_elevator;

 id[elevator2_tile] := id_elevator2;
 id[elevator2_tile+1] := id_elevator2;

 id[battery_tile] := id_battery;
 id[battery_tile+1] := id_battery;
 id[battery2_tile] := id_battery;
 id[battery2_tile+1] := id_battery;

 assign(f,'map/lvl03_id.bin'); rewrite(f, 1);
 blockwrite(f, id, sizeof(id));
 close(f);
{
 for j:=0 to 9 do begin
  for i:=0 to 7 do write(id[i+j*8],',');

  writeln;
 end;
}
end;

(*---------------------------------------------------*)

procedure level3;		// level #4
const
	empty_tile = 0;

	empty1_tile = 60;	// 60..61
	empty2_tile = 68;	// 68..69
	empty3_tile = 50;	// 50..51

	empty5_tile = 58;

	brick_tile = 9;		// 9..10

	floor_tile = 23;

	teleport_in_tile = 71;
	teleport_out_tile = 15;

	downbar_tile = 49;	// common
	death_tile = 14;

	lava_tile = 38;

	battery_tile = 11;	// 11..12
	battery2_tile = 34;	// 34..35

	elevator_tile = 30;	// 30..31
	elevator2_tile = 32;	// 32..33
begin

 fillbyte(id, sizeof(id), 0);

 id[floor_tile] := id_floor;

 id[empty_tile] := id_empty;

 id[empty1_tile] := id_empty;
// id[empty1_tile+1] := id_empty;

 id[empty2_tile] := id_empty;
 id[empty2_tile+1] := id_empty;
// id[empty2_tile+2] := id_empty;
// id[empty2_tile+3] := id_empty;
// id[empty2_tile+4] := id_empty;

 id[empty3_tile] := id_empty;
 id[empty3_tile+1] := id_empty;

 id[empty5_tile] := id_empty;


 id[teleport_in_tile] := id_teleport_in;
 id[teleport_in_tile+1] := id_teleport_in;

 id[teleport_out_tile] := id_teleport_out;
 id[teleport_out_tile+1] := id_teleport_out;


 id[brick_tile]	:= id_brick_left;
 id[brick_tile+1] := id_brick_right;

 id[downbar_tile] := id_downbar;

 id[death_tile] := id_death;

 id[lava_tile] := id_lava;

 id[elevator_tile] := id_elevator;
 id[elevator_tile+1] := id_elevator;

 id[elevator2_tile] := id_elevator2;
 id[elevator2_tile+1] := id_elevator2;

 id[battery_tile] := id_battery;
 id[battery_tile+1] := id_battery;
 id[battery2_tile] := id_battery;
 id[battery2_tile+1] := id_battery;

 assign(f,'map/lvl04_id.bin'); rewrite(f, 1);
 blockwrite(f, id, sizeof(id));
 close(f);
{
 for j:=0 to 9 do begin
  for i:=0 to 7 do write(id[i+j*8],',');

  writeln;
 end;
}
end;


begin

 level0;
 level1;
 level2;
 level3;

 writeln('Done.');

 repeat until keypressed;


end.