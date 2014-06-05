//
// UNIX2003.c
// Redland-ObjC
//
// Created by Marcus Rohrmoser on 18.05.14.
// Copyright (c) 2014 Marcus Rohrmoser mobile Software. All rights reserved.
//


#include <dirent.h>
#include <stdio.h>
#include <time.h>
#include <regex.h>
#include <string.h>
#include <stdlib.h>

/** https://stackoverflow.com/questions/9575023/xcode-code-coverage-and-fopenunix2003
 */
DIR *opendir$INODE64$UNIX2003(const char *dirname)
{
    return opendir(dirname);
}


int fputs$UNIX2003(const char *__restrict s, FILE *__restrict stream)
{
    return fputs(s, stream);
}


time_t mktime$UNIX2003(struct tm *timeptr)
{
    return mktime(timeptr);
}


int regcomp$UNIX2003(regex_t *restrict preg, const char *restrict pattern, int cflags)
{
    return regcomp(preg, pattern, cflags);
}


char *strerror$UNIX2003(int i)
{
    return strerror(i);
}


size_t strftime$UNIX2003(char *restrict s, size_t maxsize, const char *restrict format, const struct tm *restrict timeptr)
{
    return strftime(s, maxsize, format, timeptr);
}


double strtod$UNIX2003(const char *restrict nptr, char **restrict endptr)
{
    return strtod(nptr, endptr);
}

// void rewinddir$INODE64$UNIX2003(DIR *dir) { rewinddir(dir); }
