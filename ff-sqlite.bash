#!/bin/bash
# Copyright (c) 2012-2013 Fatih Bostancı <faopera@gmail.com>
# GPLv3
# v1.0.4

[[ $(pgrep firefox) ]] && { printf 'firefox çalışıyor.\n'; exit 1; }

set -e
for veritabani in ~/.mozilla/firefox/*/*.sqlite
do
  printf '%-40s%s' "\`${veritabani##*/}' işleniyor..." \
    "[B:$(du -h $veritabani | awk '{printf "%5s%s", $1,"B -> "}')"
  sqlite3 $veritabani vacuum
  sqlite3 $veritabani reindex
  printf "S:$(du -h $veritabani | awk '{printf "%5s%s", $1,"B]"}')\n"
done

# vim: set ts=2 sw=2 et:
