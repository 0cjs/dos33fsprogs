0HGR:HCOLOR=5:FORX=0TO278:HPLOTX,83TOX,73+RND(1)*5:POKE8192+RND(1)*4096,1:NEXT
2A$="*-4:Dz":FORY=83TO160:HCOLOR=0:IFY=2*ASC(MID$(A$,Z+1,1))THENZ=Z+1:HCOLOR=6
3HPLOT0,YTOX,Y:NEXT
5VTAB21:?,"/\":FORQ=1TO20:Y=SQR(400-Q*Q):HCOLOR=RND(1)*7:FORT=99-QTO99+Q:HPLOTT,20-YTOT,18+Y:NEXTT,Q
