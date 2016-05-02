#!/bin/bash
ddir=/mnt/raid1/kai
if ! test -d $ddir
then
	mount /mnt/raid1 \# first
fi
rsync --remove-source-files -Pr mediadir/ $ddir
