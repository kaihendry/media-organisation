#!/bin/bash
shopt -s nocasematch

kernel=$(uname -s)
case $kernel in
	Darwin) stat=gstat
	;;
	*) stat=stat
esac

moving=$(mktemp) || exit

for i in "$@"
do

# we require a directory
if ! test -d "$i"
then
	echo ERROR: Arg1 \""$i"\" must be a directory 1>&2
	exit 1
fi

dir="$i"

for media in "${dir%/}"/*
do
	case $media in
		*.jpg|*.jpeg|*.mov|*.mp4|*.fcpbundle)
			dateprefix="mysrctree/$($stat -c %y "$media" | awk '{print $1}')/$(basename "$media")"
			mkdir -p "$(dirname "$dateprefix")"
			echo -e "$media\\t$dateprefix" >> "$moving"
			;;
		*)
		echo Ignoring "$media"
	esac
done

done

# Nothing to move, we exit
test -s "$moving" || exit

cat "$moving"

read -p "Are you sure? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    while IFS=$'\t' read -r src dest
	do
		mv -v "$src" "$dest"
	done < "$moving"
fi
