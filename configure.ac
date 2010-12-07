#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.65])
AC_INIT([plurker], [0.1], [david@wu-man.com])

AM_MAINTAINER_MODE([enable])
AM_INIT_AUTOMAKE([-Wall -Werror foreign])

# Checks for programs.
AC_PROG_CC
AM_PROG_VALAC([0.8.0])

# Checks for libraries.
PKG_CHECK_MODULES([PLURK], [plurk], [], [AC_MSG_ERROR([$PACKAGE_NAME depends on plurk])])
VALA_FLAGS="--pkg plurk --pkg posix"

# Checks for header files.

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.

AC_SUBST(VALA_FLAGS)

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
