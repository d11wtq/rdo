/*
 * RDO—Ruby Data Objects.
 * Copyright © 2012 Chris Corbyn.
 *
 * See LICENSE file for details.
 */

#include <ruby.h>
#include <stdio.h>
#include <string.h>

/** Quote parameters in params array */
static char ** rdo_driver_quote_params(VALUE self, VALUE * args, int argc, long * len) {
  char ** quoted = malloc(sizeof(char *) * argc);
  int  idx = 0;
  VALUE tmp;

  *len = 0;

  for (; idx < argc; ++idx) {
    switch (TYPE(args[idx])) {
      case T_NIL:
        quoted[idx] = strdup("NULL");
        *len += 4;
        break;

      case T_FIXNUM:
      case T_FLOAT:
        tmp = rb_funcall(args[idx], rb_intern("to_s"), 0);
        Check_Type(tmp, T_STRING);

        quoted[idx] = strdup(RSTRING_PTR(tmp));
        *len += RSTRING_LEN(tmp);
        break;

      default:
        tmp = rb_funcall(self, rb_intern("quote"), 1, args[idx]);
        Check_Type(tmp, T_STRING);

        quoted[idx] = malloc(sizeof(char) * (RSTRING_LEN(tmp) + 3));
        sprintf(quoted[idx], "'%s'", RSTRING_PTR(tmp));
        *len += 2 + RSTRING_LEN(tmp);
        break;
    }
  }

  return quoted;
}

/** Release heap memory allocated for quoted params */
static void rdo_driver_free_params(char ** quoted, int len) {
  int i;
  for (i = 0; i < len; ++i) free(quoted[i]);
  free(quoted);
}

/**
 * Takes String stmt, which contains ? markers and interpolates the values in Array params.
 *
 * Each value in Array params that is not NilClass, Fixnum or Float is passed
 * to #quote on the Driver.
 *
 * Non-numeric values are surrounded by String quote.
 *
 * @param VALUE (String) stmt
 *   SQL, possibly containining '?' markers.
 *
 * @param VALUE (Array) params
 *   arguments to interpolate in place of the ? markers
 *
 * @return VALUE (String)
 *   the same SQL with the parameters interpolated.
 */
static VALUE rdo_driver_interpolate(VALUE self, VALUE stmt, VALUE params) {
  Check_Type(stmt,   T_STRING);
  Check_Type(params, T_ARRAY);

  int  argc   = RARRAY_LEN(params);
  long buflen = 0;
  char ** quoted_params = rdo_driver_quote_params(
      self,
      RARRAY_PTR(params), argc,
      &buflen);
  char buffer[buflen + RSTRING_LEN(stmt) + 1];

  char * b = buffer;
  char * s = RSTRING_PTR(stmt);
  int    n = 0;

  int insquote = 0;
  int indquote = 0;
  int inmlcmt  = 0;
  int inslcmt  = 0;

  // this loop is intentionally kept procedural (for performance)
  for (; *s; ++s, ++b) {
    switch (*s) {
      case '\\':
        if (!insquote && !indquote && !inmlcmt && !inslcmt && *(s + 1) == '?')
          ++s;

        *b = *s;
        break;

      case '?':
        if (insquote || indquote || inmlcmt || inslcmt) {
          *b = *s;
        } else {
          if (n < argc) {
            strcpy(b, quoted_params[n]);
            b += strlen(quoted_params[n]) - 1;
          } else {
            *b = *s;
          }
          ++n;
        }
        break;

      case '-':
        if (!insquote && !indquote && !inmlcmt && *(s + 1) == '-') {
          inslcmt = 1;
          *(b++) = *(s++);
        }
        *b = *s;
        break;

      case '\r':
      case '\n':
        inslcmt = 0;
        *b = *s;
        break;

      case '/':
        if (!insquote && !indquote && !inslcmt && *(s + 1) == '*') {
          ++inmlcmt;
          *(b++) = *(s++);
        }
        *b = *s;
        break;

      case '*':
        if (inmlcmt && *(s + 1) == '/') {
          --inmlcmt;
          *(b++) = *(s++);
        }
        *b = *s;
        break;

      case '\'':
        if (!indquote && !inmlcmt && !inslcmt) insquote = !insquote;
        *b = *s;
        break;

      case '"':
        if (!insquote && !inmlcmt && !inslcmt) indquote = !indquote;
        *b = *s;
        break;

      default:
        *b = *s;
    }
  }

  *b = '\0';

  rdo_driver_free_params(quoted_params, argc);

  if (n != argc) {
    rb_raise(rb_eArgError,
        "Bind parameter mismatch (%i for %i) in query %s",
        argc, n, RSTRING_PTR(stmt));
  }

  return rb_str_new2(buffer);
}

/** Extension initializer */
void Init_rdo(void) {
  rb_require("rdo/driver");
  VALUE cDriver = rb_path2class("RDO::Driver");
  rb_define_method(cDriver, "interpolate", rdo_driver_interpolate, 2);
}
