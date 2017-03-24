#!/bin/bash -e

timerange=/tmp/import-date-range
for i in {0..30}; do date --rfc-3339=date --date="$i days ago"; done > /tmp/import-date-range

convertsecs() {
	printf '%d days %dh:%dm:%ds\n' $((${1} / 86400)) $((${1}/3600)) $((${1}%3600/60)) $((${1}%60))
}

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
	exiv2 -T rename "$media" || true
	ddir=$(stat -c %y "$media" | awk '{print $1}')
	if ! grep "$ddir" "$timerange"
	then
		echo SKIPPING: $media going to $ddir is too old
		continue
	fi
	dir=$odir/$ddir
	test -d "$dir" || mkdir -v "$dir"
	rsync -trviO $move "$media" "$dir/$(basename "$media")"
done

find "$idir" -type f -iname '*.mov' -o -iname '*.mp4' | while read -r media
do
	read -r date _ < <(ffprobe -v quiet -print_format json -show_format "$media" | jq -r .format.tags.creation_time | cut -c1-10) || :
	if test "$date" && test "$date" != "null"
	then
		ddir=$date
	else
		ddir=$(stat -c %y "$media" | awk '{print $1}')
		echo \# "$media" NO METADATA... last modification date: "$ddir"
	fi
	if ! grep "$ddir" "$timerange"
	then
		echo SKIPPING: $media going to $ddir is too old
		continue
	fi
	dir=$odir/$ddir
	test -d "$dir" || mkdir -v "$dir"
	rsync -trviO $move "$media" "$dir/$(basename "$media")"
done

find "$idir" -type f -iname '*.wav' -o -iname '*.mp3' | while read -r media
do
	read -r date _ < <(ffprobe -v quiet -print_format json -show_format "$media" | jq -r .format.tags.date ) || :
	if test "$date" && test "$date" != "null"
	then
		ddir=$date
	else
		ddir=$(stat -c %y "$media" | awk '{print $1}')
		echo \# "$media" NO METADATA... last modification date: "$ddir"
	fi
	dir=$odir/$ddir
	if ! grep "$ddir" "$timerange"
	then
		echo SKIPPING: $media going to $ddir is too old
		continue
	fi
	test -d "$dir" || mkdir -v "$dir"
	rsync -trviO $move "$media" "$dir/$(basename "$media")"
done

test "$SUDO_USER" && chown -R "$SUDO_USER" out

echo $(date --rfc-3339=date) > last-synced-$(systemd-escape ${1:-iphone}).txt
