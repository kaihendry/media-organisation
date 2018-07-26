find origsrc -type f | while read -r media
do
	dateprefix="mysrctree/$(stat -c %y "$media" | awk '{print $1}')/$(basename $media)"
	mkdir -p $(dirname $dateprefix)
	mv -v $media $dateprefix
done
