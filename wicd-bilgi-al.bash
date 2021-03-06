#!/bin/bash
# Copyright (c) 2012-2015 Fatih Bostancı <faopera@gmail.com>
# GPLv3
# v1.0

# bu betiğin bulunduğu wicd dizinini görev değişkenine ata.
export gorev="$(echo $0 | awk -F'/' '{print($(NF-1))}')"
# wicd in gönderdiği değişkenleri bildirimci betiğe aktararak
# betiği çalıştır.
#
# ÖNEMLİ: bildirimci betik root üzerinde ve root sahipliğinde
# bulunmalı. Normal kullanıcı dizinine betiği eklemeyin.
# Betikleri root çalıştırdığı için betiğin normal kullanıcı
# müdahalesine açık olması tehlike oluşturur.
exec /etc/wicd/scripts/wicd-bildirimci.bash "$@"
