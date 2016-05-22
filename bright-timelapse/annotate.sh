#!/bin/bash
mkdir a
find $1 -type f -iname '*.jpg' | while read -r jpg
do
	dt=$(exiv2 -g Exif.Image.DateTime -Pv $jpg)
	read -r date time <<< "$dt"
	IFS=: read -r year month day hour min secs <<< "$date"
	IFS=: read -r hour min secs <<< "$time"
	echo $dt
	echo $year $month $day $hour $min $secs
	nicedate=$(date -d "${year}-${month}-${day}T${hour}:${min}:${secs}")

	convert $jpg -font /usr/share/fonts/windowsfonts/SourceSansPro-Bold.otf -pointsize 150 \
		-draw "gravity northwest \
		fill black  text 0,12 '$nicedate' \
		fill white  text 1,11 '$nicedate' " \
		a/$(basename $jpg .JPG).jpg

done
