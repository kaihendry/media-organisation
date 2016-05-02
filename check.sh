#!/bin/bash
find out -type f -not \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.mp4" -o -iname "*.mov" \) -o -path '*/\.*'
