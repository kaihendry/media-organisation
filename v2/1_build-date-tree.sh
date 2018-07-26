#!/bin/bash

moving=$(mktemp)

# we require a directory
test -d "$1" || exit

find $1 -type f | while read -r media
do
	dateprefix="mysrctree/$(stat -c %y "$media" | awk '{print $1}')/$(basename $media)"
	mkdir -p $(dirname $dateprefix)
	echo $media $dateprefix >> $moving
done

# Nothing to move, we exit
test -s $moving || exit

cat $moving

read -p "Are you sure? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    while read src dest
	do
		mv -v $src $dest
	done < $moving
fi
