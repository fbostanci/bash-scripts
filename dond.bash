# Copyright (c) 2012-2017 Fatih Bostancı <faopera@gmail.com>
# GPLv3
# v1.3.5
# dizin tutucu ve dizinler arası hızlı geçiş

dond() {
  local surum='1.3.5'
  local dizin="$1" ad=${FUNCNAME[0]} dz d s
  local DONDRC="$HOME/.dondrc"

  (( ! ${#DOND_DIZINLERI[@]} )) && \
  [[ -r ${DONDRC} ]] && source "${DONDRC}"

  (( ${#DOND_DIZINLERI[@]} )) && {
    declare -n dizin_dizisi=DOND_DIZINLERI
    if [[ ! " ${dizin_dizisi[@]} " =~ " $HOME " ]]
    then
        dizin_dizisi=( "$HOME" "${dizin_dizisi[@]}" )
    fi
  }

  (( ! ${#dizin_dizisi[@]} )) && dizin_dizisi+=( "$HOME" )
  [[ ${dizin} = @(.|-) ]] && dizin="$(pwd)"

  # $dizin bir sayı ise
  if [[ ${dizin} =~ ^-?[0-9]+([.][0-9]+)?$  ]]
  then
      dizin=${dizin%.*}
      # $dizin, dizin_dizisi eleman sayısından küçükse
      if (( dizin < ${#dizin_dizisi[@]} ))
      then
          # $dizin negatif ise
          (( dizin < 0 )) && {
            printf "%s: Girilen dizin indisi 0'dan küçük olamaz.\n" "${ad}"
            return 1
          }
          # dizin_dizisi elemana sahipse dizin değiştir.
          (( ${#dizin_dizisi[@]} )) && cd "${dizin_dizisi[$dizin]}"

      # $dizin, dizin_dizisi eleman sayısından büyükse
      elif (( dizin >= ${#dizin_dizisi[@]} ))
      then
          printf '%s: Girilen dizin indisi en fazla %d olabilir.\n' \
            "${ad}" "$(( ${#dizin_dizisi[@]} - 1 ))"
      fi

  # $dizin bir dizinse
  elif [[ -d ${dizin} ]]
  then
      ESKI_IFS=$IFS
      IFS=$'\n'

      for dz in ${dizin_dizisi[*]}
      do
        if [[ ${dz} = $(realpath "${dizin}") ]]
        then
            printf '%s: %s daha önceden eklenmiş.\n' "${ad}" "${dizin%/}"
            return 1
        fi
      done
      IFS=$ESKI_IFS

      dizin_dizisi+=( "$(realpath "${dizin}")" )
      printf '%s: %s eklendi.\nToplam eklenmiş dizin: %d\n' \
        "${ad}" "${dizin%/}" "$(( ${#dizin_dizisi[@]} - 1 ))"

  elif [[ ${dizin} = -@(-listele|l) ]]
  then
      for ((d=1; d<${#dizin_dizisi[@]}; d++))
      do
        printf '%d-> %s\n' "$d" "${dizin_dizisi[$d]}"
      done

  elif [[ ${dizin} = -@(-s[iı]f[iı]rla|s) ]]
  then
      unset dizin_dizisi && printf '%s: dizin dizisi sıfırlandı.\n' "${ad}"
      [[ -r ${DONDRC} ]] && source "${DONDRC}"

  elif [[ ${dizin} = -@(-[oö]nceki|[oö]) ]]
  then
      cd - > /dev/null 2>&1 || \
        printf '%s: önceki dizin bulunmuyor.\n' "${ad}"

  elif [[ ${dizin} = -@(-sil|-remove|r) ]]
  then
      if [[ -n $2 && $2 =~ ^[0-9]+([.][0-9]+)?$ ]]
      then
          s="$2"
          s=${s%.*}
          if [[ -n ${dizin_dizisi[$s]} ]]
          then
              unset "dizin_dizisi[$s]"
              printf '%s: dizin elemanı silindi.\n' "${ad}"
              dizin_dizisi=("${dizin_dizisi[@]}")
          else
              printf '%s: dizinin %s. elemanı bulunmuyor.\n1<=dizin_elemanı<=%d\n' \
                "${ad}" "$s" "$(( ${#dizin_dizisi[@]} - 1 ))"
          fi
      else
          printf '%s: hatalı dizin silme isteği: %s\n' \
            "${ad}" "${s:-null}"
      fi

  elif [[ ${dizin} = -@(-yaz|y) ]]
  then
cat <<DOND > "${DONDRC}"
# ${ad} v${surum} yapılandırma dosyası

DOND_DIZINLERI=(
$(printf "'%s'\n" "${dizin_dizisi[@]}")
)
DOND
  printf '%s: %s dosyasına dizin dizisi yazıldı.\n' \
    "${ad}" "${DONDRC}"

  elif [[ ${dizin} = -@(-yard[ıi]m|-help|h) ]]
  then
      echo "
        ${ad} ${surum}

        kullanım:
        ${ad} [.|-]
        ${ad} [dizin|seçenek|dizin_no]

        Seçenekler:
        -l, --listele
          eklenmiş dizinleri numaralarıyla sıralar.

        -s, --sifirla
          dizin listesini varsayılana dönüştürür.

        -r, --remove, --sil <dizin_no>
          dizin listesinden girilen dizini siler.

        -o, --onceki
          bir önceki konuma geri döner.

        -y, --yaz
          geçerli dizin listesini dosyaya yazar.

        -h, --help, --yardim
          bu yardım çıktısını görüntüler.
           " >&2

  # fonksiyon değişken verilmeden çalıştırılıyorsa
  # varsayılan dizine git.
  elif [[ ! ${dizin} ]]
  then
      cd "${dizin_dizisi[0]}"

  else
      printf '%s: Geçersiz dizin adı/değişken\n' "${ad}"

  fi
}

# vim: set ts=2 sw=2 et:
