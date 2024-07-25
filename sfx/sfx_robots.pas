uses crt, atari, xSFX;

// if you want play SFX on SECOND POKEY
//uses sfx_config;

const
	sfx1: array of byte =	// upadek Preliminary Monte
	[
	{$i sfx.inc}
	];

var

	sfx: TSFX;

begin
	writeln(high(sfx1));
	
	//audctl:=1;
	
	sfx.clear;
	sfx.add(@sfx1);


	while true do begin

	 pause;
	 sfx.play;

	 if keypressed then begin

	  readkey;

    	  sfx.init(1);

	 end;

	end;
end.