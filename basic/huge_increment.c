/*
 * In this example, a huge increment at one block causes the WCET to exceed the bound.
 * Only one path exceeds the bound. Compared to huge_increment_inverted.c, the observation
 * is that analyzing the tree from left to right or from right to left can make differences
 * in number of subsumptios and also total instructions traversed.
 */
#ifdef LLBMC
#include <llbmc.h>
#else
#include <klee/klee.h>
#endif

int main() {
// Will cause error
  char s[100];
// Safe
//  char s[1000];
  char *p;
  int a,b,c;

#ifdef LLBMC
  a = __llbmc_nondef_int();
  b = __llbmc_nondef_int();
  c = __llbmc_nondef_int();
#else
  klee_make_symbolic(&a, sizeof(int), "a");
  klee_make_symbolic(&b, sizeof(int), "b");
  klee_make_symbolic(&c, sizeof(int), "c");
#endif

  p = s;

  if (a == 0)
     p+=1;
  else
     p+=2;
  if (b == 0)
     p+=3;
  else
     p+=4;
  if (c == 0)
     p+=5;
  else
     p+=94;

  // p should be in s
  return *p;
} 


