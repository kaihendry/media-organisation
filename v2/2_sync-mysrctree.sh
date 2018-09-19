#!/bin/bash
rsync --remove-source-files -vaihhHSP --exclude "*Render Files*" --exclude "*Analysis Files*" --omit-dir-times mysrctree/ freenas:/mnt/red/redsamba
