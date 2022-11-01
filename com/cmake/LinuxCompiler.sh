#!/bin/bash

if [[ "$1" == "gcc" ]] ; then
	COMPILER="$(ls "/usr/bin/gcc-"* | egrep "^\/usr\/bin\/gcc-[0-9]{1,2}$" | sort -V | tail -n 1)"
elif [[ "$1" == "g++" ]] ; then
	COMPILER="$(ls "/usr/bin/g++-"* | egrep "^\/usr\/bin\/g\\+\\+-[0-9]{1,2}$" | sort -V | tail -n 1)"
else
	exit 1
fi

if command -v "${COMPILER}" > /dev/null ; then
	echo -n "${COMPILER}"
	exit 0
else
	exit 1
fi

exit 0