dnl Check for a C type equivalent to a Fortran type.
dnl
dnl FA_CHECK_CTYPE_FORTRAN(ftype, ctypes)
dnl
AC_DEFUN([FA_CHECK_CTYPE_FORTRAN],
[
    cat >conftestf.f <<EOF
           $1 values(4)
           data values /-1, -2, -3, -4/
           call sub(values)
           end
EOF
    for ctype in $2; do
	AC_MSG_CHECKING(if Fortran \"$1\" is C \"$ctype\")
	cat >conftest.c <<EOF
            #include <stdlib.h>
	    void $FCALLSCSUB(values)
		$ctype values[[4]];
	    {
		exit(values[[1]] != -2 || values[[2]] != -3);
	    }
EOF
	doit='$CC -c ${CPPFLAGS} ${CFLAGS} conftest.c'
	if AC_TRY_EVAL(doit); then
	    doit='$F77 ${FFLAGS} -c conftestf.f'
	    if AC_TRY_EVAL(doit); then
	        doit='$F77 -o conftest ${FFLAGS} ${LDFLAGS} conftestf.o conftest.o ${FLIBS} ${LIBS}'
	        if AC_TRY_EVAL(doit); then
		    doit=./conftest
		    if AC_TRY_EVAL(doit); then
		        AC_MSG_RESULT(yes)
                        m4_toupper(FORTRAN_$1_CTYPE)=$ctype
                        AC_SUBST(m4_toupper(FORTRAN_$1_CTYPE))
                        AC_DEFINE_UNQUOTED(m4_toupper(FORTRAN_$1_CTYPE), [$ctype], [Fortran to C conversion])
		        break
		    else
		        AC_MSG_RESULT(no)
		    fi
	        else
		    AC_MSG_ERROR(Could not link conftestf.o and conftest.o)
	        fi
	    else
		AC_MSG_ERROR(Could not compile conftestf.f)
	    fi
	else
	    AC_MSG_ERROR(Could not compile conftest.c)
	fi
    done
    rm -f conftest*
])
