/*
 * RDO—Ruby Data Objects.
 * Copyright © 2012 Chris Corbyn.
 *
 * See LICENSE file for details.
 */

/** -------------------------------------------------------------------------
 * These macros are for use by RDO driver developers.
 *
 * They simplify the logic needed when converting types provided by the RDBMS
 * into their equivalent Ruby types.
 *
 * All of these macros take a C string and return a Ruby VALUE.
 *
 * The actual logic for many of the conversions is handled in RDO::Util, which
 * is written in Ruby.
 * --------------------------------------------------------------------------
 */

#include <ruby.h>
#include <ruby/encoding.h>

/**
 * Convenience to call #to_s on any Ruby object.
 */
#define RDO_OBJ_TO_S(obj) (rb_funcall(obj, rb_intern("to_s"), 0))

/**
 * Raise an RDO::Exception with the given msg format and any number of parameters.
 *
 * @param (char *) msg
 *   a format string passed to rb_raise()
 *
 * @param (void *) ...
 *   args used to interpolate the error message
 */
#define RDO_ERROR(...) (rb_raise(rb_path2class("RDO::Exception"), __VA_ARGS__))

/**
 * Factory to return a new RDO::Result for an Enumerable object of tuples.
 *
 * @param VALUE (Enumerable) tuples
 *   an object that knows how to iterate all tuples
 *
 * @param VALUE (Hash)
 *   an optional hash of query info.
 *
 * @return VALUE (RDO::Result)
 *   a new Result object
 */
#define RDO_RESULT(tuples, info) \
  (rb_funcall(rb_path2class("RDO::Result"), rb_intern("new"), 2, tuples, info))

/**
 * Wrap the given StatementExecutor in a RDO::Statement.
 *
 * @param VALUE
 *   any object that responds to #command and #execute
 *
 * @return VALUE
 *   an RDO::Statement
 */
#define RDO_STATEMENT(executor) \
  (rb_funcall(rb_path2class("RDO::Statement"), rb_intern("new"), 1, executor))

/**
 * Convert a C string to a ruby String.
 *
 * @param (char *) s
 *   a C string that is valid in the default encoding
 *
 * @param (size_t) len
 *   the length of the string
 *
 * @return VALUE (String)
 *   a Ruby String
 */
#define RDO_STRING(s, len, enc) \
  (rb_enc_associate_index(rb_str_new(s, len), enc > 0 ? enc : 0))

/**
 * Convert a C string to a ruby String, assuming possible NULL bytes.
 *
 * @param (char *) s
 *   a C string, possibly containing nulls
 *
 * @param (size_t) len
 *   the length of the string
 *
 * @return VALUE (String)
 *   a Ruby String
 */
#define RDO_BINARY_STRING(s, len) (rb_str_new(s, len))

/**
 * Convert a C string to a Fixnum.
 */
#define RDO_FIXNUM(s) (rb_cstr2inum(s, 10))

/**
 * Convert a C string to a Float.
 *
 * This supports Infinity and NaN.
 *
 * @param (char *) s
 *   a C string representing a float (e.g. "1.234")
 *
 * @return VALUE (Float)
 *   a ruby Float
 */
#define RDO_FLOAT(s) \
  (rb_funcall(rb_path2class("RDO::Util"), \
              rb_intern("float"), 1, rb_str_new2(s)))

/**
 * Convert a C string representing a precision decimal into a BigDecimal.
 *
 * @param (char *) s
 *   a C string representing a decimal ("1.245")
 *
 * @return VALUE (BigDecimal)
 *   a BigDecimal representation of this string
 *
 * @example
 *   RDO_DECIMAL("1.234")
 *   => #<BigDecimal:7feb42b2b6e8,'0.1234E1',18(18)>
 */
#define RDO_DECIMAL(s) \
  (rb_funcall(rb_path2class("RDO::Util"), \
              rb_intern("decimal"), 1, rb_str_new2(s)))

/**
 * Convert a C string representing a date into a Date.
 *
 * @param (char *) s
 *   the C string with a parseable date
 *
 * @return VALUE (Date)
 *   a Date, exactly as was specified in the input
 *
 * @example
 *   RDO_DATE("431-09-22 BC")
 *   #<Date: -0430-09-22 ((1564265j,0s,0n),+0s,2299161j)>
 */
#define RDO_DATE(s) \
  (rb_funcall(rb_path2class("RDO::Util"), \
              rb_intern("date"), 1, rb_str_new2(s)))

/**
 * Convert a C string representing a date & time with no time zone into a DateTime.
 *
 * @param (char *) s
 *   the C string with the date & time provided
 *
 * @return VALUE (DateTime)
 *   a DateTime, assuming the system time zone
 *
 * @example
 *   RDO_DATE_TIME_WITHOUT_ZONE("2012-09-22 04:36:12")
 *   #<DateTime: 2012-09-22T04:36:12+10:00 ((2456192j,66972s,0n),+36000s,2299161j)>
 */
#define RDO_DATE_TIME_WITHOUT_ZONE(s) \
  (rb_funcall(rb_path2class("RDO::Util"), \
              rb_intern("date_time_without_zone"), 1, rb_str_new2(s)))

/**
 * Convert a C string representing a date & time that includes a time zone into a DateTime.
 *
 * @param (char *) s
 *   the C string with the date & time provided, including the time zone
 *
 * @return VALUE (DateTime)
 *   a DateTime, exactly as was specified in the input
 *
 * @example
 *   RDO_DATE_TIME_WITHOUT_ZONE("2012-09-22 04:36:12+10:00")
 *   #<DateTime: 2012-09-22T04:36:12+10:00 ((2456192j,66972s,0n),+36000s,2299161j)>
 */
#define RDO_DATE_TIME_WITH_ZONE(s) \
  (rb_funcall(rb_path2class("RDO::Util"), \
              rb_intern("date_time_with_zone"), 1, rb_str_new2(s)))

/**
 * Convert a boolean string to TrueClass/FalseClass.
 *
 * @param (char *) s
 *   a C string that is either 't', 'true', 'f' or 'false'
 *
 * @return VALUE (TrueClass, FalseClass)
 *   the boolean representation
 */
#define RDO_BOOL(s) ((s[0] == 't') ? Qtrue : Qfalse)
