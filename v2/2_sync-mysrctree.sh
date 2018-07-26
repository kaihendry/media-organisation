#!/bin/bash
rsync --remove-source-files -vaihhHSP --omit-dir-times mysrctree/ hendry@freenas.local:/mnt/red/redsamba
