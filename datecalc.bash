#!/bin/bash
# Copyright (c) 2011-2015 Fatih Bostancı <faopera@gmail.com>
# GPLv3
# v1.0.1

# TODO: Gelişmiş yollarla yeniden yazılacak.

[ ${#} -eq 0 ] && {
  birim=1
  if  test -x "$(which zenity 2>/dev/null)"
  then
      arayuz=1
    elif test -x "$(which kdialog 2>/dev/null)"
  then
      arayuz=2
  fi
  if [ $arayuz -eq 1 ]
  then
      secilen_tarih=`zenity --calendar --date-format='%m/%d/%Y' --title 'Tarih Seçimi'\
        --text 'İstediğiniz tarihi seçiniz'` || exit 1
      secilen_saat=`zenity --entry --text 'İstenilen tarih için saati girin (9:30 için 0930)' --title 'Saat Sorgusu'` || exit 1

  elif [ $arayuz -eq 2 ]
  then
      secilen_tarih_ham=`kdialog --calendar  'İstediğiniz tarihi seçiniz' --title 'Tarih Seçimi'`
      secilen_tarih=`date -d "$secilen_tarih_ham" +%m/%d/%Y`

      secilen_saat=`kdialog --inputbox 'İstenilen tarih için saati girin (9:30 için 0930)' --title 'Saat Sorgusu'` || exit 1
  fi
} || {
  birim=2
  girilen_tarih=$1

  secilen_tarih=`echo $girilen_tarih | gawk -F'/' 'BEGIN{OFS="/";} {print $2,$1,$3;}'`
  secilen_saat=$2
}

secilen_tarih_yil=`date -d "$secilen_tarih" +%Y` || exit 1
secilen_tarih_ay=`date -d "$secilen_tarih" +%m` || exit 1
export $(echo $secilen_saat | sed 's:[0-9][0-9]:&\ :' | gawk '{print "saat="$1, "\ndakika="$2}')


secilen_tarih_saniye_ham=`date -d "$secilen_tarih" +%s` || exit 1
secilen_tarih_saniye=`expr $saat \* 3600 + $dakika \* 60 + $secilen_tarih_saniye_ham` || exit 1

sonuc_yil_ham=`expr $(date +%Y) - $secilen_tarih_yil`
sonuc_yil_ref=`expr $sonuc_yil_ham \* 12 - $secilen_tarih_ay + $(date +%m)`
sonuc_yil=$(($sonuc_yil_ref/12))

simdi_saniye=`date --date='now' +%s`
sonuc_saniye=`expr $simdi_saniye - $secilen_tarih_saniye`

sonuc_saat=$((sonuc_saniye/3600))
sonuc_dakika=$((sonuc_saniye/60))
sonuc_gun=$((sonuc_saniye/86400))
sonuc_ay=$((sonuc_gun/30))

sonuc_24=$(printf '%d saat : %d dakika : %d saniye' $((sonuc_saat%24)) $((sonuc_dakika%60)) $((sonuc_saniye%60)))

tarih_duzen=$(echo $secilen_tarih | gawk -F'/' 'BEGIN{OFS="/";} {print $2,$1,$3;}')
saat_duzen=$(echo $secilen_saat | sed 's:[0-9][0-9]:&\::')

if [ $birim -eq 1 ]
then
    if [ $arayuz -eq 1 ]
    then
        zenity --info --title 'Geçen süre' --text "\'$tarih_duzen $saat_duzen\' \
tarihinden bu yana \
\n\n<big>
$sonuc_yil yıl
$sonuc_ay ay
$sonuc_gun gün
$sonuc_saat saat
$sonuc_dakika dakika
$sonuc_saniye saniye
</big>\ngeçmiş.\n
Şu an ile seçilen gün arasındaki saat farkı:
$sonuc_24
" --timeout 25
    elif  [ $arayuz -eq 2 ]
    then
        kdialog --msgbox "'$tarih_duzen $saat_duzen' \
tarihinden bu yana \
\n\n
$sonuc_yil yıl
$sonuc_ay ay
$sonuc_gun gün
$sonuc_saat saat
$sonuc_dakika dakika
$sonuc_saniye saniye
\ngeçmiş.\n
Şu an ile seçilen gün arasındaki saat farkı:
$sonuc_24
" --title 'Geçen süre'
    fi

elif [ $birim -eq 2 ]
then
    echo -e "\033[1m'$tarih_duzen $saat_duzen' \
\033[1;32mtarihinden bu yana \n
\033[1;33m$sonuc_yil\033[0;1m yıl
\033[1;33m$sonuc_ay\033[0;1m ay
\033[1;33m$sonuc_gun\033[0;1m gün
\033[1;33m$sonuc_saat\033[0;1m saat
\033[1;33m$sonuc_dakika\033[0;1m dakika
\033[1;33m$sonuc_saniye\033[0;1m saniye
\ngeçmiş...\n
Şu an ile seçilen gün arasındaki saat farkı:\n
\033[1;33m$sonuc_24
\033[0m"
fi

# vim: set ts=2 sw=2 et:
