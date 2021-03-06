#!/bin/bash
# based on cmus-status-display
# Copyright (c) 2012-2015 Fatih Bostancı <faopera@gmail.com>
# GPLv3
# v1.0.2

# Dependencies: cmus,bash,sed,libnotify
# Usage: in cmus command ":set status_display_program=where-is-this-script"

function cikti() {
#replace some Turkish characters which are not looking properly..  
  _cikti=$(echo "$@" | sed 's:ð:ğ:g;s:Ý:İ:g;s:þ:ş:g;s:ý:ı:g;s:Þ:Ş:g;s:Ð:Ğ:g')
  notify-send 'cmus-notifier' "${_cikti}" -t 15000 -i ${gorsel}
}

while test $# -ge 2
do
  eval _$1='$2'
  shift 2
done

    if [[ ${_status} = playing ]]
    then
        c_durum='>'
        gorsel=media-playback-start
    elif [[ ${_status} = paused ]]
    then
        c_durum='||'
        gorsel=media-playback-pause
    elif [[ ${_status} = stopped ]]
    then
        c_durum='&#62;o&#60;'
        gorsel=media-playback-stop
    fi

if test -n "${_file}"
then
    h=$((_duration/3600))
    m=$((_duration%3600))

    test $h -gt 0 && dur="$h:"
    sure="${dur}$(printf '%02d:%02d' $((m/60)) $((m%60)))"

    if [[ -n ${_album} ]]
    then
        c_album="\n${_album}"
    else
        c_album=''
    fi
    if [[ -n $_date ]]
    then
        c_date="  ($_date)\n"
    else
        c_date='\n'
    fi
    cikti "${c_durum} ${_artist} - ${_title}${c_album}${c_date}${sure}"

elif test -n "${_url}"
then
    cikti "${c_durum} ${_title}\n${_url}"
    #printf "$(date +'%x %X')  ${_title}  ${_url}\n" >> ~/.cmus-net-tracklist
else
    cikti "${c_durum}"
fi
