/*
 * MazeGen.c -- Mark Howell -- 8 May 1991
 *
 * Usage: MazeGen [width [height [seed]]]
 */
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define WIDTH 39
#define HEIGHT 11

#define UP 0
#define RIGHT 1
#define DOWN 2
#define LEFT 3
#ifdef TRUE
#undef TRUE
#endif /* TRUE */

#define TRUE 1

#define cell_empty(a) (!(a)->up && !(a)->right && !(a)->down && !(a)->left)

typedef struct {
    unsigned int up      : 1;
    unsigned int right   : 1;
    unsigned int down    : 1;
    unsigned int left    : 1;
    unsigned int path    : 1;
    unsigned int visited : 1;
} cell_t;
typedef cell_t *maze_t;

void CreateMaze (maze_t maze, int width, int height);
void SolveMaze (maze_t maze, int width, int height);
void PrintMaze (maze_t maze, int width, int height);
/*
int main (int argc, char *argv [])
{
    int width = WIDTH;
    int height = HEIGHT;
    maze_t maze;

    if (argc >= 2)
        width = atoi (argv [1]);

    if (argc >= 3)
        height = atoi (argv [2]);

    if (argc >= 4)
        srand (atoi (argv [3]));
    else
        srand ((int) time ((time_t *) NULL));

    if (width <= 0 || height <= 0) {
        (void) fprintf (stderr, "Illegal width or height value!\n");
        exit (EXIT_FAILURE);
    }
    maze = (maze_t) calloc (width * height, sizeof (cell_t));
    if (maze == NULL) {
        (void) fprintf (stderr, "Cannot allocate memory!\n");
        exit (EXIT_FAILURE);
    }
    CreateMaze (maze, width, height);

    PrintMaze (maze, width, height);

    (void) putchar ('\n');

    SolveMaze (maze, width, height);

    PrintMaze (maze, width, height);

    free (maze);
    exit (EXIT_SUCCESS);

    return (0);

}*/


void CreateMaze (maze_t maze, int width, int height)
{
    maze_t mp, maze_top;
    char paths [4];
    int visits, directions;

    visits = width * height - 1;
    mp = maze;
    maze_top = mp + (width * height) - 1;

    while (visits) {
        directions = 0;

        if ((mp - width) >= maze && cell_empty (mp - width))
            paths [directions++] = UP;
        if (mp < maze_top && ((mp - maze + 1) % width) && cell_empty (mp + 1))
            paths [directions++] = RIGHT;
        if ((mp + width) <= maze_top && cell_empty (mp + width))
            paths [directions++] = DOWN;
        if (mp > maze && ((mp - maze) % width) && cell_empty (mp - 1))
            paths [directions++] = LEFT;

        if (directions) {
            visits--;
            directions = ((unsigned) rand () % directions);

            switch (paths [directions]) {
                case UP:
                    mp->up = TRUE;
                    (mp -= width)->down = TRUE;
                    break;
                case RIGHT:
                    mp->right = TRUE;
                    (++mp)->left = TRUE;
                    break;
                case DOWN:
                    mp->down = TRUE;
                    (mp += width)->up = TRUE;
                    break;
                case LEFT:
                    mp->left = TRUE;
                    (--mp)->right = TRUE;
                    break;
                default:
                    break;
            }
        } else {
            do {
                if (++mp > maze_top)
                    mp = maze;
            } while (cell_empty (mp));
        }
    }
}/* CreateMaze */


void SolveMaze (maze_t maze, int width, int height)
{
    maze_t *stack, mp = maze;
    int sp = 0;

    stack = (maze_t *) calloc (width * height, sizeof (maze_t));
    if (stack == NULL) {
        (void) fprintf (stderr, "Cannot allocate memory!\n");
        exit (EXIT_FAILURE);
		return;
    }
    (stack [sp++] = mp)->visited = TRUE;

    while (mp != (maze + (width * height) - 1)) {

        if (mp->up && !(mp - width)->visited)
            stack [sp++] = mp - width;
        if (mp->right && !(mp + 1)->visited)
            stack [sp++] = mp + 1;
        if (mp->down && !(mp + width)->visited)
            stack [sp++] = mp + width;
        if (mp->left && !(mp - 1)->visited)
            stack [sp++] = mp - 1;

        if (stack [sp - 1] == mp)
            --sp;

        (mp = stack [sp - 1])->visited = TRUE;
    }
    while (sp--)
        if (stack [sp]->visited)
            stack [sp]->path = TRUE;

    free (stack);

}/* SolveMaze */


void PrintMaze (maze_t maze, int width, int height)
{
    int w, h;
    char *line, *lp;

    line = (char *) calloc ((width + 1) * 2, sizeof (char));
    if (line == NULL) {
        (void) fprintf (stderr, "Cannot allocate memory!\n");
        exit (EXIT_FAILURE);
    }
    maze->up = TRUE;
    (maze + (width * height) - 1)->down = TRUE;

    for (lp = line, w = 0; w < width; w++) {
        *lp++ = '+';
        if ((maze + w)->up)
            *lp++ = ((maze + w)->path) ? '.' : ' ';
        else
            *lp++ = '-';
    }
    *lp++ = '+';
    (void) puts (line);
    for (h = 0; h < height; h++) {
        for (lp = line, w = 0; w < width; w++) {
            if ((maze + w)->left)
                *lp++ = ((maze + w)->path && (maze + w - 1)->path) ? '.' : ' ';
            else
                *lp++ = '|';
            *lp++ = ((maze + w)->path) ? '.' : ' ';
        }
        *lp++ = '|';
        (void) puts (line);
        for (lp = line, w = 0; w < width; w++) {
            *lp++ = '+';
            if ((maze + w)->down)
                *lp++ = ((maze + w)->path && (h == height - 1 ||
                         (maze + w + width)->path)) ? '.' : ' ';
            else

                *lp++ = '-';
        }
        *lp++ = '+';
        (void) puts (line);
        maze += width;
    }
    free (line);

}


void PrintMazeArray (maze_t maze, int width, int height, NSMutableArray *a)
{
    int w, h;
    char *line, *lp;
	
    line = (char *) calloc ((width + 1) * 2, sizeof (char));
    if (line == NULL) {
        (void) fprintf (stderr, "Cannot allocate memory!\n");
        exit (EXIT_FAILURE);
    }
    maze->up = TRUE;
    (maze + (width * height) - 1)->down = TRUE;
	
    for (lp = line, w = 0; w < width; w++) {
        *lp++ = '#';
        if ((maze + w)->up)
            *lp++ = ((maze + w)->path) ? '#' : ' ';
        else
            *lp++ = '#';
    }
    *lp++ = '+';
    [a addObject:[NSString stringWithUTF8String:line]];
    for (h = 0; h < height; h++) {
        for (lp = line, w = 0; w < width; w++) {
            if ((maze + w)->left)
                *lp++ = ((maze + w)->path && (maze + w - 1)->path) ? '#' : ' ';
            else
                *lp++ = '#';
            *lp++ = ((maze + w)->path) ? '#' : ' ';
        }
        *lp++ = '#';
    [a addObject:[NSString stringWithUTF8String:line]];
	 for (lp = line, w = 0; w < width; w++) {
		 *lp++ = '#';
            if ((maze + w)->down)
                *lp++ = ((maze + w)->path && (h == height - 1 ||
											  (maze + w + width)->path)) ? '#' : ' ';
            else
				
                *lp++ = '#';
        }
        *lp++ = '#';
    [a addObject:[NSString stringWithUTF8String:line]];
	 maze += width;
    }
    free (line);
	
}