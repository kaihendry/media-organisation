#!/bin/bash

ddir=/mnt/raid1/kai
if ! test -d $ddir
then
	echo Please: mount /mnt/raid1
	exit
fi
rsync --remove-source-files -Pr "${1:-$HOME/media/out/}" $ddir

./delete-empty-dirs.sh
