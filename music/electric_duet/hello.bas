   2  HOME 
   5  PRINT 
  10  PRINT "ELECTRIC DUET DEMOS"
  20  PRINT 
  30  PRINT "1. STILL ALIVE"
  35  PRINT "2. FF7 FIGHTING"
  40  PRINT "3. FF7 HIGHWIND"
  45  PRINT "4. KERBAL THEME"
  50  PRINT "5. KOROBEINIKI (TETRIS THEME)"
  55  PRINT "6. PEASANT'S QUEST"
  60  PRINT "7. FORTNIGHT (BREAKDANCE RAT)"
 100  PRINT  CHR$ (4)"BLOAD ED"
 120  PRINT "-----> ";: INPUT A
 130  IF A < 0 OR A > 7 THEN  GOTO 120
 140  ON A GOTO 200,210,220,230,240,250,260
 200  PRINT  CHR$ (4)"BLOAD SA.ED,A$2000"
 205  GOTO 1000
 210  PRINT  CHR$ (4)"BLOAD FIGHTING.ED,A$2000"
 215  GOTO 1000
 220  PRINT  CHR$ (4)"BLOAD HIGHWIND.ED,A$2000"
 225  GOTO 1000
 230  PRINT  CHR$ (4)"BLOAD KERBAL.ED,A$2000"
 235  GOTO 1000
 240  PRINT  CHR$ (4)"BLOAD KORO.ED,A$2000"
 245  GOTO 1000
 250  PRINT  CHR$ (4)"BLOAD PEASANT.ED,A$2000"
 255  GOTO 1000
 260  PRINT  CHR$ (4)"BLOAD FORTNIGHT.ED,A$2000"
 265  GOTO 1000
1000  POKE 30,0: POKE 31,32
1010 CALL 256*12
1020 GOTO 2
