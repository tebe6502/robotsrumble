uses crt, xSFX;

// if you want play SFX on SECOND POKEY
//uses sfx_config;

const
	sfx1: array of byte =	// upadek Preliminary Monte
	[
	{$i sfx0.inc}
	];

var

	sfx: TSFX;

begin
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