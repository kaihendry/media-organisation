#!/bin/bash -e

show_help() {
cat << EOF
Usage: ${0##*/} [-hm] [SRC_DIR] [DEST_DIR]
Arrange source directory media by YYYY-MM-DD prefix in DEST_DIR

    -m          Move files
EOF
}

move=""

OPTIND=1 # Reset is necessary if getopts was used previously in the script.  It is a good idea to make this local in a function.
while getopts "hm" opt; do
    case "$opt" in
        h)
            show_help
            exit 0
            ;;
        m)  move="--remove-source-files"
            ;;
        '?')
            show_help >&2
            exit 1
            ;;
    esac
done
shift "$((OPTIND-1))" # Shift off the options and optional --.

idir="${1:-/mnt/iphone/DCIM}"
odir="${2:-$HOME/media/out}"
test -d "$odir" || mkdir -p "$odir"
if test "$idir" = "/mnt/iphone/DCIM"
then
	if test "$EUID" -eq 0
	then
		ifuse /mnt/iphone
		trap 'umount /mnt/iphone' EXIT
	else
		echo You need to be root
		exit 1
	fi
fi

test -d "$idir" || exit

find "$idir" -type f \( -iname "*.jpg" -o -iname "*.png" \) -not -path '*/\.*' | while read -r media
do
	read -r date _ < <(exiv2 -g Exif.Image.DateTime -Pv "$media" ) || :
	if test "$date"
	then
		IFS=: read -r year month day <<< "$date"
		dir=$odir/$year-$month-$day
	else
		dir=$odir/$(stat -c %y "$media" | awk '{print $1}')
		echo "$media" NO EXIF... last modification date: "$dir"
	fi
		test -d "$dir" || mkdir -v "$dir"
		rsync $move -P "$media" "$dir/$(basename "$media")"
done
find "$idir" -type f -iname '*.mov' -o -iname '*.mp4' | while read -r media
do
	read -r date _ < <(ffprobe -v quiet -print_format json -show_format "$media" | jq -r .format.tags.creation_time ) || :
	if test "$date" && test "$date" != "null"
	then
		dir=$odir/$date
	else
		dir=$odir/$(stat -c %y "$media" | awk '{print $1}')
		echo \# "$media" NO EXIF... last modification date: "$dir"
	fi
		test -d "$dir" || mkdir -v "$dir"
		rsync $move -P "$media" "$dir/$(basename "$media")"
done
