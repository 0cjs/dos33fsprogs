1 REM BASED ON CODE BY B. BUCKELS
2 REM http://www.appleoldies.ca/bmp2dhr/basic/
3  D$ =  CHR$ (4): PRINT D$;"PR#3": PRINT : REM ENABLE 80 COL
5  TEXT
6  HOME
24 POKE 49232,0: REM GRAPHICS
25 POKE 49234,0: REM FULL GRAPHICS
26 POKE 49236,0: REM PAGE ONE
27 POKE 49239,0: REM HI-RES ON
28 POKE 49246,0: REM DOUBLE HI-RES ON
100 TEMP$="CUBE_PINK":GOSUB 1000
105 GET A$
110 TEMP$="CUBE_WHITE":GOSUB 1000
115 GET A$
120 TEMP$="CUBE_BLACK":GOSUB 1000
125 GET A$
710  POKE 49233,0: REM TEXT MODE
720  POKE 49247,0: REM DOUBLE HI-RES OFF
730  POKE 49236,0: REM PAGE ONE
800  TEXT
810  HOME 
820 END
1000 PRINT
1005  POKE 49237,0: PRINT D$;"BLOAD ";TEMP$;".AUX, A$2000":PRINT
1010  POKE 49236,0: PRINT D$;"BLOAD ";TEMP$;".BIN, A$2000":PRINT
1020 RETURN