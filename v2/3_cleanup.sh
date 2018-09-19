#!/bin/bash
# TODO excluded files
find ${1:-mysrctree} -name .DS_Store -type f -delete
find ${1:-mysrctree} -type d -empty -delete
