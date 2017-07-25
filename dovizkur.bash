#!/bin/bash
#Copyright (c) 2017 Fatih Bostancı <faopera@gmail.com>
# v0.2
# GPLv3
# Türkiye Cumhuriyet Merkez Bankası(TCMB) döviz kurlarını
# gösterici betik

if ! type -p wget &>/dev/null
then
    echo wget gerekli
    exit 1
elif ! type -p xmlstarlet &>/dev/null
then
    echo xmlstarlet gerekli
    exit 1
fi

# öntanımlı renkli gösterim açık (1)
# kapatmak için RENK_KULLAN daki 1'i 0 yapın.
# öntanımlı ayar kalsın anlık renk durumu değişsin için
# RENK=0: renkler kapalı
# RENK=1: renkler açık (öntanımlı kapalı ise)
# örnek: öntanımlı renkler açık, anlık kapatma için
# export RENK=0; bash dovizkur.bash
RENK_KULLAN=${RENK:-1}

(( RENK_KULLAN )) && {
  R0='\033[0m' # Renk yok
  R1='\033[0;1m' # Renk beyaz
  R2='\033[1;33m' # Renk sari
  R3='\033[1;32m' # Renk yeşil
  R4='\033[1;36m' # Renk mavi
} || {
  R0=''
  R1=''
  R2=''
  R3=''
  R4=''
}

wget -t 1 --quiet http://www.tcmb.gov.tr/kurlar/today.xml -O /tmp/doviz-kurlari

readarray -t birimler     < <(xmlstarlet sel -t -v '//Unit' /tmp/doviz-kurlari)
readarray -t doviz_adi    < <(xmlstarlet sel -t -v '//Isim' /tmp/doviz-kurlari)
readarray -t alis_fiyati  < <(xmlstarlet sel -t -v '//ForexBuying' /tmp/doviz-kurlari)
readarray -t satis_fiyati < <(xmlstarlet sel -t -v '//ForexSelling' /tmp/doviz-kurlari)

doviz_adi[3]='EURO     '
doviz_adi[10]='S.ARABİSTAN RİYALİ'

birimler=( 'Birim' "${birimler[@]}" )
doviz_adi=( 'Döviz Adı' "${doviz_adi[@]}" )
alis_fiyati=( 'Alış' "${alis_fiyati[@]}" )
satis_fiyati=( 'Satış' "${satis_fiyati[@]}" )

case $1 in
  --dolar)
    aralik='0 1' ;;
  --euro)
    aralik='0 4' ;;
  --yen)
    aralik='0 12' ;;
  --eus) # euro ve dolar
    aralik='0 1 4' ;;
  *)
    aralik="$(seq 0 18)" ;;
esac

for i in ${aralik}
do
  printf '%b %b %b %b\n' "${R3}${birimler[$i]}" "${R1}${doviz_adi[$i]}" \
                         "${R2}${alis_fiyati[$i]}" "${R4}${satis_fiyati[$i]}${R0}"
done | column -t
