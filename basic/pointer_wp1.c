/*
 * Copyright 2016, 2017 National University of Singapore
 *
 * This program is for testing memory bounds check interpolation: it
 * should have subsumptions not just at/near the end of the traces.
 */
#ifdef LLBMC
#include <llbmc.h>
#else
#include <klee/klee.h>
#endif

int main(int argc, char **argv)
{
  char s[14];
  int p1, p2, p3;
  char *p;

#ifdef LLBMC
  p1 = __llbmc_nondef_int();
  p2 = __llbmc_nondef_int();
  p3 = __llbmc_nondef_int();
#else
  klee_make_symbolic(&p1, sizeof(int), "p1");
  klee_make_symbolic(&p2, sizeof(int), "p2");
  klee_make_symbolic(&p3, sizeof(int), "p3");
#endif

  p = s;

  if (p1) {
    p += 3;
  } else {
    p += 2;
  }
  if (p2) {
    p += 3;
  } else {
    p += 2;
  }
  if (p3) {
    p += 3;
  } else {
    p += 2;
  }

  // p should be in s
  return *p;
}

