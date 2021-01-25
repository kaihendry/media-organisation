#!/bin/bash
rsync -LvrihhHSP --remove-source-files --exclude "Transcoded Media" --exclude=".*" --exclude "*Render Files*" --exclude "*Analysis Files*" --omit-dir-times mysrctree/ 192.168.1.2:/mnt/red/redsamba
