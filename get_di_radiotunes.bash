#!/bin/bash
# Copyright (c) 2014-2015 Fatih Bostancı <faopera@gmail.com>
# GPLv3
# credits: http://mpd.wikia.com/wiki/Hack:di.fm-playlists

function get_radiotunes() {
  mkdir -p radiotunes && cd radiotunes

  wget -q -O - http://listen.radiotunes.com/public1 | sed 's/},{/\n/g' | \
  perl -n -e '/"key":"([^"]*)".*"playlist":"([^"]*)"/; print "$1\n"; system("wget -q -O - $2 | grep -E '^File' | cut -d= -f2 > radiotunes_$1.m3u")'
  cd - &>/dev/null
}

function get_di_fm() {
  mkdir -p di.fm && cd di.fm

  wget -q -O - http://listen.di.fm/public1 | sed 's/},{/\n/g' | \
  perl -n -e '/"key":"([^"]*)".*"playlist":"([^"]*)"/; print "$1\n"; system("wget -q -O - $2 | grep -E '^File' | cut -d= -f2 > di_$1.m3u")'
  cd - &>/dev/null
}

case $1 in
  --di) get_di_fm ;;
  --sky|--radiotunes) get_radiotunes ;;
  --all) get_di_fm && get_radiotunes ;;
esac