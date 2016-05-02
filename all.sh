#!/bin/bash -e
idir="${1:-/mnt/iphone/DCIM}"
odir="${2:-mediadir}"
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
	read -r date time < <(exiv2 -g Exif.Image.DateTime -Pv "$media" ) || :
	if test "$date"
	then
		IFS=: read -r year month day <<< "$date"
		dir=$odir/$year-$month-$day
	else
		dir=$odir/$(stat -c %y "$media" | awk '{print $1}')
		echo "$media" NO EXIF... last modification date: "$dir"
	fi
		test -d "$dir" || mkdir -v "$dir"
		echo rsync --remove-source-files -P "$media" "$dir/$(basename "$media")"
		rsync --remove-source-files -P "$media" "$dir/$(basename "$media")"
done
find "$idir" -type f -iname '*.mov' -o -iname '*.mp4' | while read -r media
do
	read -r date time < <(ffprobe -v quiet -print_format json -show_format "$media" | jq -r .format.tags.creation_time ) || :
	if test "$date"
	then
		dir=$odir/$date
	else
		dir=$odir/$(stat -c %y "$media" | awk '{print $1}')
		echo \# "$media" NO EXIF... last modification date: "$dir"
	fi
		test -d "$dir" || mkdir -v "$dir"
		rsync --remove-source-files -P "$media" "$dir/$(basename "$media")"
done
