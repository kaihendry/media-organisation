#!/bin/bash
rsync -vaihhHSP --exclude "Transcoded Media" --exclude "*Render Files*" --exclude "*Analysis Files*" --omit-dir-times mysrctree/ 192.168.1.2:/mnt/red/redsamba
