/*
 * maz.c - generate a maze
 *
 * algorithm posted to rec.games.programmer by jallen@ic.sunysb.edu
 * program cleaned and reorganized by mzraly@ldbvax.dnet.lotus.com
 *
 * don't make people pay for this, or I'll jump up and down and
 * yell and scream and embarass you in front of your friends...
 *
 * compile: cc -o maz -DDEBUG maz.c
 *
 */
#include <stdio.h>
#include <time.h>

static int      multiple = 57;  /* experiment with this? */
static int      offset = 1;     /* experiment with this? */

int ___maze(char maz[], int y, int x, char vc, char hc, char fc);
void mazegen(int pos, char maz[], int y, int x, int rnd);


/*
 * maze() : generate a random maze of size (y by x) in maz, using vc as the
 * vertical character, hc as the horizontal character, and fc as the floor
 * character
 *
 * maz is an array that should already have its memory allocated - you could
 * malloc a char string if you like.
 */
int ___maze(char maz[], int y, int x, char vc, char hc, char fc)
{
   int             i, yy, xx;
   int             max = (y * x);
   int             rnd = (int)time(0L);

   /* For now, return error on even parameters */
   /* Alternative is to decrement evens by one */
   /* But really that should be handled by caller */
   if (!(y & 1) | !(x & 1))
      return (1);

   /* I never assume... */
   for (i = 0; i < max; ++i)
      maz[i] = 0;

   (void) mazegen((x + 1), maz, y, x, rnd);

   /* Now replace the 1's and 0's with appropriate chars */
   for (yy = 0; yy < y; ++yy) {
      for (xx = 0; xx < x; ++xx) {
         i = (yy * x) + xx;

         if (yy == 0 || yy == (y - 1))
            maz[i] = hc;
         else if (xx == 0 || xx == (x - 1))
            maz[i] = vc;
         else if (maz[i] == 1)
            maz[i] = fc;
         else if (maz[i - x] != fc && maz[i - 1] == fc
                 && (maz[i + x] == 0 || (i % x) == (y - 2)))
            maz[i] = vc;
         else
            maz[i] = hc;       /* for now... */
      }
   }
   return (0);
}


/*
 * mazegen : do the recursive maze generation
 *
 */
void mazegen(int pos, char maz[], int y, int x, int rnd)
{
   int             d, i, j;

   maz[pos] = 1;
   while ((d = (pos <= x * 2 ? 0 : (maz[pos - x - x] ? 0 : 1))
          | (pos >= x * (y - 2) ? 0 : (maz[pos + x + x] ? 0 : 2))
          | (pos % x == x - 2 ? 0 : (maz[pos + 2] ? 0 : 4))
          | (pos % x == 1 ? 0 : (maz[pos - 2] ? 0 : 8)))) {

      do {
         rnd = (rnd * multiple + offset);
         i = 3 & (rnd / d);
      } while (!(d & (1 << i)));

      switch (i) {
      case 0:
         j = -x;
         break;
      case 1:
         j = x;
         break;
      case 2:
         j = 1;
         break;
      case 3:
         j = -1;
         break;
      default:
		 j = 0;
         break;
      }

      maz[pos + j] = 1;

      mazegen(pos + 2 * j, maz, y, x, rnd);
   }

   return;
}
#ifdef DEBUG
#define kMaxY 40
#define kMaxX 80

main(int argc, char *argv[])
{
   extern int      optind;
   extern char    *optarg;
   int             x = 40;
   int             y = 28;
   char            hor = '-';
   char            ver = '|';
   char            flo = ' ';
   char            maz[kMaxY * kMaxX];
   int             i;

   while ((i = getopt(argc, argv, "h:v:f:y:x:m:o:")) != EOF)
      switch (i) {
      case 'h':
         hor = *optarg;
         break;
      case 'v':
         ver = *optarg;
         break;
      case 'f':
         flo = *optarg;
         break;
      case 'y':
         y = atoi(optarg);
         break;
      case 'x':
         x = atoi(optarg);
         break;
      case 'm':
         multiple = atoi(optarg);
         break;
      case 'o':
         offset = atoi(optarg);
         break;
      case '?':
      default:
         (void) fprintf(stderr, "usage: maz [xyhvfmo]\n");
         break;
      }

   if (maze(maz, y, x, ver, hor, flo) == 0) {
      for (i = 0; i < (x * y); ++i) {
         (void) putchar(maz[i]);
         if (((i + 1) % x) == 0)
            (void) putchar('\n');
      }
   } else {
      (void) fprintf(stderr, "Couldn't make the maze\n");
   }

   exit(0);
}
#endif
