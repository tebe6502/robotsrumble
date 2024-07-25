// RMT PLAYER

uses crt, rmt;

const
	rmt_player = $a000;
	rmt_modul = $4000;

var
	msx: TRMT;

	ch: char;

{$r 'sfx.rc'}


begin
	//while true do begin

	msx.player:=pointer(rmt_player);
	msx.modul:=pointer(rmt_modul);

	msx.init(6);	// 0,2,4,6,8,10

	writeln('Pascal RMT player example');

	repeat until keypressed;
	ch:=readkey();


	repeat
		pause;

		msx.play;

	until keypressed;
	ch:=readkey();

	msx.stop;

	//end;

end.
