0Q=38:GR:FORI=0TO9:X(I)=RND(1)*Q:Y(I)=I:COLOR=1:VLIN33,QAT16+I:COLOR=4:HLIN9-I/2,9+I/2AT28+I:COLOR=8:VLIN29,33AT16+I:NEXT:VLIN36,QAT20:HLIN0,QAT39:PLOT9,Q
3FORI=0TO9:V=X(I):W=Y(I):COLOR=15:PLOTV,W:PLOTV,W+1:COLOR=0:IFSCRN(V,W+2)>0THENX(I)=RND(1)*Q:W=0
6PLOTV,W:Y(I)=W+1:NEXT:GOTO3