#!/bin/bash
# Copyright (c) 2013-2015 Fatih Bostancı <faopera@gmail.com>
# GPLv3
# v1.0.3

_sudo_gerekli=0
_paket_gerekli=0

set -e

function calistir() {
  local bu_komutu_calistir

  (( _sudo_gerekli  )) && bu_komutu_calistir="sudo ${komut}" || bu_komutu_calistir="${komut}"
  (( _paket_gerekli )) && [[ -z ${paket} ]] &&
  { printf \
      "HATA: Çalıştırılacak \`%s' komutunun çalışması için bir paket adı girmelisiniz. Çıkılıyor...\n" \
      "${bu_komutu_calistir}"; exit 1
  } || bu_komutu_calistir+=" ${paket}"

  ! (( $(id -u) )) && ! (( _sudo_gerekli )) &&
    printf "UYARI: Çalıştırılacak \`%s' komutunun çalışması için yönetici hakları gerekmiyor.\n" \
      "${bu_komutu_calistir}"

  printf "Çalıştırılacak komut: %s\n" "${bu_komutu_calistir}"
  eval ${bu_komutu_calistir}
}

function paket_de_kurulacak_mı() {
  local _paket="$@"

  [[ -n ${_paket} ]] && {
    printf "Çalıştırılacak komut: %s\n" "sudo apt-get install ${_paket}"
    sudo apt-get install ${_paket}
  }
}

case $1 in
  -S)
    _sudo_gerekli=1
    _paket_gerekli=1
    komut="apt-get install"
    shift; paket="$@"
    calistir ;;
  -Sy)
    _sudo_gerekli=1
    komut="apt-get update"
    calistir; shift
    paket_de_kurulacak_mı "$@" ;;
  -Su)
    _sudo_gerekli=1
    komut="apt-get upgrade"
    calistir; shift
    paket_de_kurulacak_mı "$@" ;;
  -Syu|-Suy)
    _sudo_gerekli=1
    komut="apt-get update"
    calistir
    komut="apt-get upgrade"
    calistir; shift
    paket_de_kurulacak_mı "$@" ;;
  -Ss)
    _paket_gerekli=1
    komut="apt-cache search"
    shift; paket="$1"
    calistir ;;
  -Sc) 
    _sudo_gerekli=1
    komut="apt-get clean"
    calistir ;;
  -Scc)
    _sudo_gerekli=1
    komut="apt-get autoclean"
    calistir ;;
  -Si)
    _paket_gerekli=1
    komut="dpkg-query -s"
    shift; paket="$@"
    calistir ;;
  -Sw)
    _paket_gerekli=1
    komut="apt-get dowload"
    shift; paket="$@"
    calistir ;;
  -R|-Rn)
    _sudo_gerekli=1
    _paket_gerekli=1
    komut="apt-get remove"
    shift; paket="$@"
    calistir ;;
  -Rs)
    _sudo_gerekli=1
    _paket_gerekli=1
    komut="apt-get autoremove"
    shift; paket="$@"
    calistir ;;
  -Rns|-Rsn)
    _sudo_gerekli=1
    _paket_gerekli=1
    komut="apt-get purge"
    shift; paket="$@"
    calistir
    _paket_gerekli=0
    paket=""
    komut="apt-get autoremove"
    calistir ;;
  -U)
    _sudo_gerekli=1
    _paket_gerekli=1
    komut="dpkg -i"
    shift; paket="$@"
    calistir
    _paket_gerekli=0
    paket=""
    komut="apt-get install -f"
    calistir ;;
  -Qi)
    _paket_gerekli=1
    komut="dpkg-query -s"
    shift; paket="$@"
    calistir ;;
  -Ql)
    _paket_gerekli=1
    komut="dpkg -L"
    shift; paket="$@"
    calistir ;;
  --*)
    printf "Uzun seçenekler desteklenmiyor\n"; exit 1 ;;
  *)
    printf "Hatalı ya da olmayan/desteklenmeyen seçenek\n"; exit 1 ;;
esac

# vim: set ts=2 sw=2 et:
