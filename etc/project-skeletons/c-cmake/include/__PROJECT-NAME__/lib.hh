#ifndef __(upcase (alist-get "__PROJECT-NAME__" subs nil nil #'string-equal))___LIB_H
#define __(upcase (alist-get "__PROJECT-NAME__" subs nil nil #'string-equal))___LIB_H

#include <stdio.h>

void hello(const char* target) {
  printf("Hello %s\n", target);
}

#endif /* __(upcase (alist-get "__PROJECT-NAME__" subs nil nil #'string-equal))___LIB_H */
