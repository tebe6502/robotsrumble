uses crt;

const

	box_corner = 45;
	box_top = 46;
	box_left = 47;
	box_right = 48;
	box_bottom = 49;
	
	panel_ofset = 80;

var
	panel_map: array of byte = [ {$bin2csv panel.bin} ];		// panel po prawej stronie ekranu

	i,j: byte;


procedure tile_panel(a,x,y: byte);
begin

 panel_map[x-28 + y*8]:=a;

end;


begin

  for j:=0 to 23 do 
   for i:=0 to 7 do inc(panel_map[i+j*8], panel_ofset);

  tile_panel(box_corner, 28,0);
  tile_panel(box_corner, 28+7,0);
  tile_panel(box_corner, 28,23);
  tile_panel(box_corner, 28+7,23);

  for i:=5 downto 0 do begin
   tile_panel(box_top, 29+i,0);
   tile_panel(box_bottom, 29+i,23);
  end;

  for i:=21 downto 0 do begin     
   tile_panel(box_left, 28,1+i);
   tile_panel(box_right, 28+7,1+i);
  end;
 
 
  for j:=0 to 23 do begin
   for i:=0 to 7 do 
    write('$',hexStr(panel_map[i+j*8],2),',');

   if j<>23 then writeln;
  end;
 
 
 repeat until keypressed;
  

end.
