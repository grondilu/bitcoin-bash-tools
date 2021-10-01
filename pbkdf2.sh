#!/usr/bin/env bash

pbkdf2_step() {
  local c hash_name="$1" key="$2"
  printf '%02x' "${@:3}" |
  xxd -p -r |
  openssl dgst -"$hash_name" -hmac "$key" -binary |
  xxd -p -c 1 |
  while read -r
  do echo $((0x$REPLY))
  done
}
function pbkdf2() {
  case "$PBKDF2_METHOD" in
    python)
      python -c "import hashlib; \
      print( \
        hashlib.pbkdf2_hmac( \
          \"$1\", \
          \"$2\".encode(\"utf-8\"), \
          \"$3\".encode(\"utf-8\"), \
          $4, \
          ${5:None} \
          ).hex()
      )"
      ;;
    *)
      # Translated from https://github.com/bitpay/bitcore/blob/master/packages/bitcore-mnemonic/lib/pbkdf2.js
      # /**
      # * PBKDF2
      # * Credit to: https://github.com/stayradiated/pbkdf2-sha512
      # * Copyright (c) 2014, JP Richardson Copyright (c) 2010-2011 Intalio Pte, All Rights Reserved
      # */
      local hash_name="$1" key_str="$2" salt_str="$3"
      local -ai key salt u t block1
      local -i hLen
      hLen="$(openssl dgst "-$hash_name" -binary <<<"foo" |wc -c)"
      local -i iterations=$4 dkLen=${5:-hLen}
      local -i i j k l=$(( (dkLen+hLen-1)/hLen ))

      for ((i=0; i<${#key_str}; i++))
      do printf -v "key[$i]" "%d" "'${key_str:i:1}"
      done

      for ((i=0; i<${#salt_str}; i++))
      do printf -v "salt[$i]" "%d" "'${salt_str:i:1}"
      done

      block1=(${salt[@]} 0 0 0 0)

      for ((i=1;i<=l;i++))
      do
        block1[${#salt[@]}+0]=$((i >> 24 & 0xff))
        block1[${#salt[@]}+1]=$((i >> 16 & 0xff))
        block1[${#salt[@]}+2]=$((i >>  8 & 0xff))
        block1[${#salt[@]}+3]=$((i >>  0 & 0xff))
        
        u=($(pbkdf2_step "$hash_name" "$key_str" "${block1[@]}"))
        printf "\rPBKFD2: bloc %d/%d, iteration %d/%d" $i $l 1 $iterations >&2
        t=(${u[@]})
        for ((j=1; j<iterations; j++))
        do
          printf "\rPBKFD2: bloc %d/%d, iteration %d/%d" $i $l $((j+1)) $iterations >&2
          u=($(pbkdf2_step "$hash_name" "$key_str" "${u[@]}"))
          for ((k=0; k<hLen; k++))
          do t[k]=$((t[k]^u[k]))
          done
        done
        echo >&2
        
        dk+=(${t[@]})

      done
      printf "%02x" "${dk[@]:0:dkLen}"
      echo
    ;;
  esac
}

