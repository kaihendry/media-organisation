cat brightness-results/* | sort -n | tail -n100 | awk '{print $2}' | while read gj; do cp $gj bright/; done

