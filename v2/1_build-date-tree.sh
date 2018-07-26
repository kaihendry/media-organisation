#!/bin/bash
shopt -s nocaseglob

kernel=$(uname -s)
case $kernel in
	Darwin) stat=gstat
	;;
	*) stat=stat
esac

moving=$(mktemp)

# we require a directory
test -d "$1" || exit

dir="$1"

for media in "$dir"/*
do
	case $media in
		*.jpg|*.mp4|*.fcpbundle)
			dateprefix="mysrctree/$($stat -c %y "$media" | awk '{print $1}')/$(basename "$media")"
			mkdir -p "$(dirname "$dateprefix")"
			echo "$media" "$dateprefix" >> "$moving"
			;;
		*)
		echo Ignoring "$media"
	esac
done

# Nothing to move, we exit
test -s "$moving" || exit

cat "$moving"

read -p "Are you sure? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    while read -r src dest
	do
		mv -v "$src" "$dest"
	done < "$moving"
fi
