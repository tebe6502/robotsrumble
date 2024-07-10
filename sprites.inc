
procedure doSprites;
begin

//-------------------- clear sprites ------------------------

						// EraseBlit initialize blt_control
 ClrBlit(0, blt_copy_0 + blt_next);		// mask = $00 ; copy = 0

 ClrBlit(1, blt_copy_0 + blt_next);
 ClrBlit(2, blt_copy_0 + blt_next);
 ClrBlit(3, blt_copy_0 + blt_next);
 ClrBlit(4, blt_copy_0 + blt_next);
 ClrBlit(5, blt_copy_0 + blt_next);
 ClrBlit(6, blt_copy_0 + blt_stop);

 RunBCB(Blit0);
 while BlitterBusy do;


//--------------------- set sprites -------------------------

						// MoveBlit modifing blt_control initialize first by EraseBlit


 if (death_robot = false) and (power < 2) and (tick and 7 < 3) then
   DstBlit(0, dst0 + 200*320)			// robot blinks -> move outside the visible screen area
 else
   DstBlit(0, mul320[robot.y] + robot.x);	// mask = $ff ; copy = 1


 if enemy0.kind <> 0 then
   DstBlit(1, mul320[enemy0.y] + enemy0.x)
 else
   DstBlit(1, dst0 + 200*320);

 if enemy1.kind <> 0 then
   DstBlit(2, mul320[enemy1.y] + enemy1.x)
 else
   DstBlit(2, dst0 + 200*320);

 if enemy2.kind <> 0 then
   DstBlit(3, mul320[enemy2.y] + enemy2.x)
 else
   DstBlit(3, dst0 + 200*320);

 if enemy3.kind <> 0 then
   DstBlit(4, mul320[enemy3.y] + enemy3.x)
 else
   DstBlit(4, dst0 + 200*320);

 if enemy4.kind <> 0 then
   DstBlit(5, mul320[enemy4.y] + enemy4.x)
 else
   DstBlit(5, dst0 + 200*320);

 if enemy5.kind <> 0 then
   DstBlit(6, mul320[enemy5.y] + enemy5.x)
 else
   DstBlit(6, dst0 + 200*320);

 if enemy6.kind <> 0 then
   DstBlit(7, mul320[enemy6.y] + enemy6.x)
 else
   DstBlit(7, dst0 + 200*320);


 RunBCB(blit0);
 while BlitterBusy do;				// EraseBlit + MoveBlit works together

end;
