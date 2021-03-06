#!/bin/bash
# Copyrigtht (c) 2011-2017 Fatih Bostancı <faopera@gmail.com>
# GPLv3
# v1.0.9

# not: dosyalar betikle aynı dizinde değilse tam konumuyla beraber girilmeli.
IP_DOSYASI=ip
DECIMAL_DOSYASI=IpToCountry.csv
GECICI_DOSYA=/tmp/decimal

if ! [ -f "${DECIMAL_DOSYASI}" ]
then
    printf "${DECIMAL_DOSYASI} dosyası bulunamadı.\n" >&2
    exit 1
fi

declare -a ip_dec_list ip_list # ip lere ait decimal değerleri ve  ip dizisi

if [ -f "${IP_DOSYASI}" ]
then
    ip_list=( $(sed '/^$/d' "${IP_DOSYASI}") $@ ) # ip adreslerini listeye ekledik.
elif [[ $# -gt 0 ]]
then
    ip_list=( $@ )
else
    printf  '%s%s\n' \
            'IP_DOSYASI adresini belirleyin ' \
            'ya da ip adreslerini betiğe değişken olarak verin.' >&2
    exit 1
fi

sed -e '/^$/d' -e '/^#/d' -e 's:\"::g;s: :_:g' < "${DECIMAL_DOSYASI}" > "${GECICI_DOSYA}"

for ((i=0; i<${#ip_list[@]}; i++))
{
  IP=${ip_list[$i]//./ }
  set -- $IP
  ip_dec_list+=( $(( 16777216 * $1 + 65536 * $2 + 256 * $3 + $4 )) )
}

# ip nin decimal değerini decimal dosyasındaki değerlerle  satır satır karşılaştırıyoruz.
# çakışma varsa bilgileri ekrana yazacak.
IFS=','
while read -r bilgi
do
  for ((i=0; i<${#ip_dec_list[@]}; i++))
  {
    set -- $bilgi
    if [[ ${ip_dec_list[$i]} -ge $1 ]]  &&  [[ ${ip_dec_list[$i]} -le $2 ]]
    then
        printf '\n%s\n%-12s%s\n%-12s%s\n%-12s%s\n%s\n ' \
          '*******************************************' \
          "IP  " "= ${ip_list[$i]}" \
          "IP Decimal"  "= ${ip_dec_list[$i]} " \
          "Ulke  " "= ${7//_/ } - $5 ($6) " \
          '*******************************************'
    fi
  }
done < "${GECICI_DOSYA}"

unset IFS
rm -f "${GECICI_DOSYA}" &>/dev/null
