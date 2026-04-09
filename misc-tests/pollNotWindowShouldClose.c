#include "raylib/src/raylib.h"
#include <stdio.h>

// Idk why this doesn't work

int
pollNotWindowShouldClose()
{
        while (!WindowShouldClose()) {
                ; // poll
        }
        puts("Window must close");
        return 0;
}
