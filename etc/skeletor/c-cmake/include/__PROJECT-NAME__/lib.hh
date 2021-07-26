#ifndef __(upcase (cdr (assoc "__PROJECT-NAME__" subs)))___LIB_H
#define __(upcase (cdr (assoc "__PROJECT-NAME__" subs)))___LIB_H

#include <stdio.h>

void hello(const char* target) {
  printf("Hello %s\n", target);
}

#endif /* __(cdr (assoc "__PROJECT-NAME__" subs))___LIB_H */
