#!/bin/bash

# betiğin bulunduğu wicd dizinini görev değişkenine ata.
export gorev="$(echo $0 | awk -F'/' '{print($(NF-1))}')"
# wicd in gönderdiği değişkenleri bildirimci betiğe aktar
# ve onu çalıştır.
# ÖNEMLİ: bildirimci betik root üzerinde ve root sahipliğinde
# bulunmalı. Normal kullanıcı dizinine betiği eklemeyin.
# Betikleri root çalıştırdığı için betiğin normal kullanıcı
# müdahelesine açık olması tehlike oluşturur.
exec /etc/wicd/scripts/wicd-bildirimci.bash "$@"