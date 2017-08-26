#!/bin/bash


wget -t 1 --quiet http://www.koeri.boun.edu.tr/scripts/lasteq.asp -O - | sed -n '/<pre>/,/<\/pre>/p' | grep $(date +%Y.%m.%d) | yad --text-info --width=800 --height=600
