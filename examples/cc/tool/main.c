
#include <stdio.h>

#include "examples/cc/lib/lib.h"

int main(int argc, char *argv[]) {
    // Print the string returned from lib's greeting() function
    printf("%s, %s\n", greeting(), SECRET_2);
}
