#!/bin/bash
# http://www.imagemagick.org/discourse-server/viewtopic.php?t=11304
bdir=brightness-results
mkdir $bdir
find -type f -name '*.JPG' | while read -r jpg
do
	bjpg=$(basename "$jpg" .JPG).txt
	echo "$bdir/$bjpg"
	test -f "$bdir/$bjpg" && continue
	echo "$(convert "$jpg" -colorspace Gray -format "%[fx:quantumrange*image.mean]" info:) $jpg" > "$bdir/$bjpg"
done
