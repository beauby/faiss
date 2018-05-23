dnl Check for the name format of a Fortran-callable C routine.
dnl
dnl FA_CHECK_FCALLSCSUB
AC_DEFUN([FA_CHECK_FCALLSCSUB],
[
    case "$F77" in
        '') ;;
        *)
            AC_REQUIRE([FA_PROG_NM])
            AC_BEFORE([FA_CHECK_CTYPE_FORTRAN])
            AC_MSG_CHECKING(for C-equivalent to Fortran routine \"SUB\")
            cat >conftest.f <<\EOF
              call sub()
              end
EOF
            doit='$F77 -c ${FFLAGS} conftest.f'
            if AC_TRY_EVAL(doit); then
                FCALLSCSUB=`$NM $NMFLAGS conftest.o | awk '
                    /SUB_/{print "SUB_";exit}
                    /SUB/ {print "SUB"; exit}
                    /sub_/{print "sub_";exit}
                    /sub/ {print "sub"; exit}'`
                case "$FCALLSCSUB" in
                    '') AC_MSG_ERROR(not found)
                        ;;
                    *)  AC_MSG_RESULT($FCALLSCSUB)
                        ;;
                esac
            else
                AC_MSG_ERROR(Could not compile conftest.f)
            fi
            rm -f conftest*
            ;;
    esac
])
