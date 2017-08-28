# Copyright (c) 2012-2017 Fatih Bostancı <faopera@gmail.com>
# GPLv3
# v1.3
# dizin tutucu ve dizinler arası hızlı geçiş

dond() {
  local dizin="$1" ad=${FUNCNAME[0]} dz d

  (( ! ${#DOND_DIZINLERI[@]} )) && \
  [[ -r $HOME/.dondrc ]] && source "$HOME/.dondrc"

  (( ${#DOND_DIZINLERI[@]} )) && {
    declare -n dizin_dizisi=DOND_DIZINLERI
    if [[ ! " ${dizin_dizisi[@]} " =~ " $HOME " ]]
    then
        dizin_dizisi=( "$HOME" "${dizin_dizisi[@]}" )
    fi
  }

  (( ! ${#dizin_dizisi[@]} )) && dizin_dizisi+=( "$HOME" )
  [[ ${dizin} = @(.|-) ]] && dizin="$(pwd)"

  # $dizin tam sayı ise
  if [[ ${dizin} =~ ^-?[0-9]+([.][0-9]+)?$  ]]
  then
      # $dizin, dizin_dizisi eleman sayısından küçükse
      if (( dizin < ${#dizin_dizisi[@]} ))
      then
          # $dizin negatif ise
          (( dizin < 0 )) && {
            printf "%s: Girilen dizin indisi 0'dan küçük olamaz.\n" "${ad}"
            return 1
          }
          # dizin_dizisi elemana sahipse dizin değiştir.
          (( ${#dizin_dizisi[@]} )) && {
            onceki="$(pwd)"
            cd "${dizin_dizisi[$dizin]}"
          }

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
      [[ -r $HOME/.dondrc ]] && source "$HOME/.dondrc"

  elif [[ ${dizin} = -@(-[oö]nceki|[oö]) ]]
  then
      [[ -n ${onceki} ]] && cd "${onceki}" ||
        printf '%s: Önceki dizin bulunmuyor.\n' "${ad}"

  elif [[ ${dizin} = -@(-yaz|y) ]]
  then
cat <<DOND > "$HOME/.dondrc"
DOND_DIZINLERI=(
$(printf "'%s'\n" "${dizin_dizisi[@]}")
)
DOND
  printf '%s: %s dosyasına dizin dizisi yazıldı.\n' \
    "${ad}" "$HOME/.dondrc"

  elif [[ ${dizin} = -@(-yard[ıi]m|-help|h) ]]
  then
      echo "
        kullanım: ${ad} [.|-]  [dizin|seçenek|dizin_no]

        -l, --listele
          Eklenmiş dizinleri numaralarıyla sıralar.

        -s, --sifirla
          dizin listesini varsayılana dönüştürür.

        -o, --onceki
          bir önceki konuma geri döner.

        -y, --yaz
          geçerli dizin listesini dosyaya yazar.

        -h, --help, --yardım
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
