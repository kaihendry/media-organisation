#!/bin/bash
shopt -s nocasematch

kernel=$(uname -s)
case $kernel in
	Darwin) stat=gstat
	;;
	*) stat=stat
esac

moving=$(mktemp) || exit

# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} [-hvs] [DIR]
Stage files for a backup

    -h          display this help and exit
    -s          select files
    -v          verbose mode. Can be used multiple times for increased
                verbosity.
EOF
}

# Initialize our own variables:
verbose=0
select=0

OPTIND=1

while getopts hvs opt; do
    case $opt in
        h)
            show_help
            exit 0
            ;;
        v)  verbose=$((verbose+1))
            ;;
        s)  select=$((select+1))
            ;;
        *)
            show_help >&2
            exit 1
            ;;
    esac
done
shift "$((OPTIND-1))"   # Discard the options and sentinel --

dirs=$@

if ! test "$dirs"
then
	echo No args
	dirs=~/Movies
fi

for i in $dirs
do
# we require a directory
if ! test -d "$i"
then
	echo ERROR: \""$i"\" must be a directory 1>&2
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

if test "$select" -eq 1
then
	select dir in $(awk '{print $1}' $moving)
	do
		grep $dir $moving > $moving.bak
		mv $moving.bak $moving
		break
	done
fi

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
