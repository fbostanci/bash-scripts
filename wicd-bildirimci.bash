#!/bin/bash
# Copyright (c) 2012-2013 Fatih Bostancı <faopera@gmail.com>
# GPLv3
# v1.0

# Wicd in betiğe gönderdiği bilgiler:
# $1: wired ya da wireless bağlanma türü
# $2: essid: bağlantı noktası adı
#
#
ynt=0
# Dbus oturum adresi için oturum açmış root olmayan kullanıcının
# adını kullanıcı değişkenine atadık.
kullanici="$(who | awk '{print $1}' | sed '/^root$/d' | uniq)"

# notify-send ile iletişim için dbus adresi gerekli olduğundan
# adres tanımlı değilse adresi betik ortamına aktar.
[[ -z $DBUS_SESSION_BUS_ADDRESS ]] && {
  source /home/${kullanici}/.dbus/session-bus/*-0 &&
  export DBUS_SESSION_BUS_ADDRESS
}

function kayitci() {
  # kayıt tutma kapalı. Eğer bağlanma/kopma bilgilerini
  # saklamak istiyorsanız /dev/null yerine kayıt dosyasının
  # adıyla birlikte konumunu girin.
  local kayit_dizini=/dev/null
  local wicd_dizini="${gorev}"
  local durum

  if [[ ${wicd_dizini} = preconnect ]]
  then
      ynt=1
      durum='BAĞLANTI SAĞLANIYOR... '
      ileti='ağına bağlanıyor...'
  elif [[ ${wicd_dizini} = postconnect ]]
  then
      ynt=2
      durum='BAĞLANTI SAĞLANDI.     '
      ileti='ağına bağlanıldı.'
  elif [[ ${wicd_dizini} = predisconnect ]]
  then
      ynt=3
      durum='BAĞLANTI KESİLİYOR...  '
      ileti='ağıyla olan bağlantı kesiliyor...'
  elif [[ ${wicd_dizini} = postdisconnect ]]
  then
      ynt=4
      durum='BAĞLANTI KESİLDİ !!!   '
      ileti='ağıyla olan bağlantı koptu !..'
  fi

  echo "$(date '+%d/%m/%Y %T ::') ${durum} $@ ${ileti}" >> "${kayit_dizini}"
}

# Yalnızca wireless için betik çalışsın. Diğeri wired
if [[ $1 = wireless ]]
then
    kayitci "$2"
    # Yalnızca bağlantı koptuktan/sağlandıktan sonraki durumu için
    # bildirim ver.
    (( ynt == 2 )) && {
      # Bağlantı sağlandıktan sonra dış ip yi de göster.
      my_ip=$(curl -s http://checkip.dyndns.com/ | grep -Eo "[0-9\.]+")
      # wicd betikleri root olarak çalıştırdığı için bildirim baloncuklarını
      # normal kullanıcı ortamında gösterilmesi için ekleme yaptık.
      sudo -u "${kullanici}" DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" \
        /usr/bin/notify-send "wicd-bildirimci" \
        "$2 ${ileti}\nEIP: $my_ip" -i network-connect -t 30000
    }

    (( ynt == 4 )) && {
      sudo -u "${kullanici}" DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" \
        /usr/bin/notify-send "wicd-bildirimci" \
        "$2 ${ileti}" -i network-disconnect -t 10000
    }
fi

# vim: set ts=2 sw=2 et:
