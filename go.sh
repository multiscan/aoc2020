#!/bin/sh

if [ -n "$1" ] ; then
	d=$(printf "%02d" $1)
	echo "\n---------------------- day $d"
	ruby $d.rb 
else
	for s in *.rb ; do 
		echo "\n---------------------- day $(basename $s .rb)"
		ruby $s
	done
fi