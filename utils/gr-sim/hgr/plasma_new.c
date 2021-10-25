/* for demoscene, you need a plasma effect... */
/* https://rosettacode.org/wiki/Plasma_effect */
/* https://www.bidouille.org/prog/plasma */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <math.h>

#include "tfv_zp.h"
#include "gr-sim.h"

#define PI 3.14159265358979323846264338327950


int sine_lookup[64];

#if 0
static unsigned char color_lookup[]={0x0, 0x0, 0x1, 0x1,
				     0x2, 0x2, 0x3, 0x3,
				     0x4, 0x4, 0x5, 0x5,
				     0x6, 0x6, 0x7, 0x7};
#else
static unsigned char color_lookup[]={0x0, 0x0, 0x0, 0x1,
				     0x1, 0x1, 0x2, 0x2,
				     0x2, 0x3, 0x3, 0x3,
				     0x2, 0x2, 0x1, 0x1};

#endif

static int offscreen[40][192];

int main(int argc, char **argv) {

	int ch,xx,yy,col;

	grsim_init();

	home();

	hgr();

	soft_switch(MIXCLR);

	clear_screens();

	ram[DRAW_PAGE]=0x0;

	for(xx=0;xx<64;xx++) {

		sine_lookup[xx]=32.0*sin( (xx*2*PI)/64);

	}

	for(yy=0;yy<192;yy++) {
	for(xx=0;xx<40;xx++) {

//	col = ( 32.0 + (32.0 * sin(xx / 4.0))
  //            + 32.0 + (32.0 * sin(yy / 4.0))
    //          ) / 2;


//	col = ( 8.0 + (8.0 * sin(xx *PI/8.0))
  //            + 8.0 + (8.0 * sin(yy *PI/8.0))
    //          ) / 2;

#if 0
 	col = (int)
    (
        128.0 + (128.0 * sin(xx / 16.0))
      + 128.0 + (128.0 * sin(yy / 8.0))
      + 128.0 + (128.0 * sin((xx + yy) / 16.0))
      + 128.0 + (128.0 * sin(sqrt( (double)(xx * xx + yy * yy)) / 8.0))
    ) / 4;
//#else
 	col = (int)
    ((
        4.0 + sin(xx / 16.0)
          + sin(yy / 8.0)
          + sin((xx + yy) / 16.0)
         // + sin(sqrt(xx * xx + yy * yy) / 8.0)
    )*32) ;

	printf("%d %d %d %.2f %.2f %.2f\n",xx,yy,col,
		sin(xx/16.0), sin(yy/8.0), sin((xx+yy)/16.0));
//#endif
#else
 //	col = (int)
 //   ( 128.0 + 32*sin(xx / 16.0)
 //         + 32*sin(yy / 8.0)
 //         + 32*sin((xx + yy) / 16.0)
 //   ) ;


 	col = (int)
    ( 128.0 + sine_lookup[ (int)(xx/1)&0x3f ]
          + sine_lookup[ (int)(yy/2)&0x3f ]
//          + sine_lookup[ (int)((xx + yy)/4)&0x3f ]
    ) ;


	printf("%d %d %d %.2f %.2f %.2f\n",xx,yy,col,
		sin(xx/16.0), sin(yy/8.0), sin((xx+yy)/16.0));
#endif



			offscreen[xx][yy]=col;
		}
	}

	int offset=0;

	while(1) {
		for(yy=0;yy<192;yy++) {
			for(xx=0;xx<40;xx++) {
				col=offscreen[xx][yy];
				col+=offset;
//				col&=0x7;
//				offscreen[xx][yy]=col;
//				plot(xx,yy);
//				printf("color=%d\n",col);
//				hcolor_equals(col);
				hcolor_equals(color_lookup[col&0xf]);

				hplot(xx*7,yy);
				hplot_to((xx*7)+6,yy);
			}
		}
		offset++;
		grsim_update();

		ch=grsim_input();
		if (ch=='q') exit(0);

		if (ch==' ') {
			while(1) {
				ch=grsim_input();
				if (ch) break;
			}
		}
		usleep(200000);
	}


	return 0;
}
