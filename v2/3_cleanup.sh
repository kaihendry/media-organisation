#!/bin/bash
# TODO excluded files
# find ${1:-mysrctree} -name .DS_Store -type f -delete
# find ${1:-mysrctree} -type d -empty -delete

find mysrctree -name "Original Media" -type d -exec rmdir {} \;
echo $?
# rm -rf mysrctree
