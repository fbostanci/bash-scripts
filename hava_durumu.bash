#!/bin/bash
# Copyright (c) 2012-2013 Fatih Bostancı <faopera@gmail.com>
# GPLv3
# v1.10

# şehir adı girilirse $1 önemsenmeyecek.
SEHIR=""

degerler=()
sehirler=( ADANA ADIYAMAN AFYONKARAHISAR AGRI AMASYA ANKARA ANTALYA ARTVIN AYDIN
           BALIKESIR BILECIK BINGOL BITLIS BOLU BURDUR BURSA CANAKKALE CANKIRI
           CORUM DENIZLI DIYARBAKIR EDIRNE ELAZIG ERZINCAN ERZURUM ESKISEHIR
           GAZIANTEP GIRESUN GUMUSHANE HAKKARI HATAY ISPARTA MERSIN ISTANBUL
           IZMIR KARS KASTAMONU KAYSERI KIRKLARELI KIRSEHIR KOCAELI KONYA
           KUTAHYA MALATYA MANISA KAHRAMANMARAS MARDIN MUGLA MUS NEVSEHIR
           NIGDE ORDU RIZE SAKARYA SAMSUN SIIRT SINOP SIVAS TEKIRDAG TOKAT
           TRABZON TUNCELI SANLIURFA USAK VAN YOZGAT ZONGULDAK AKSARAY BAYBURT
           KARAMAN KIRIKKALE BATMAN SIRNAK BARTIN ARDAHAN IGDIR YALOVA KARABUK
           KILIS OSMANIYE DUZCE )

if [[ -n ${SEHIR} ]]
then
    sehir="${SEHIR}"
elif [[ -n $1 ]]
then
    [[ $1 =~ ^0 ]] && s=$(sed 's:^[0]*::' <<<$1) || s=$1
    if [[ -n $(tr -d 0-9 <<<$s) ]]
    then
        printf 'şehir trafik kodunu giriniz.\n' >&2
        exit 1
    elif [[ $s -gt ${#sehirler[@]} || $s -eq 0 ]]
    then
        printf 'şehir trafik kodunu giriniz.\n' >&2
        exit 1
    fi
    sehir=${sehirler[((s-1))]}
else
    printf 'şehir trafik kodunu giriniz.\n' >&2
    exit 1
fi

wget --quiet --timeout=15 --tries=3 -O - \
  "http://www.dmi.gov.tr/tahmin/il-ve-ilceler.aspx?m=${sehir}#sfB" | sed -n \
  '/<div id="divSonDurum">/,/<\/div>/ { 
      s:<td><em class="renk.*">\(.*\)\&.*:\1°C:p
      s:<td.*alt="\(.*\)" /> </td>:\1:p
      s:<td><em>\(.*\)</em></td>:\1:p
      s:<td.*alt="\(.*\)" /> <br /><em>\(.*\)</em></td>:\1\n\2:p
      s:<td class="sond_zaman">\(.*\)<br .>\(.*\)</td>:\1\n\2:p
   }' > /tmp/hava-sonuclari-$$

set -e
while read -r satir
do
  degerler+=( "${satir}" )
done < /tmp/hava-sonuclari-$$

rm -f /tmp/hava-sonuclari-$$ &>/dev/null
[[ ${degerler[2]} =~ ^Güncel ]] && {
  degerler[1]='Güncel Bilgi Bulunamadı!'
  degerler[2]=""
}

printf '%-20s%b\n%-19s%b\n%-21s%b\n%-19s%b\n%-21s%b\n%-22s%b\n%-22s%b\n%-25s%b\n%-20s%b\n' \
  "Şehir" "= ${sehir}" \
  "Durum" "= ${degerler[0]}" \
  "Sıcaklık" "= ${degerler[3]}" \
  "Nem" "= ${degerler[4]}" \
  "Basınç" "= ${degerler[7]}" \
  "Rüzgar hızı" "= ${degerler[6]}" \
  "Rüzgar yönü" "= ${degerler[5]}" \
  "Görüş uzaklığı" "= ${degerler[8]}" \
  "Son güncelleme" "= ${degerler[1]} ${degerler[2]}"

# vim: set ts=2 sw=2 et:
