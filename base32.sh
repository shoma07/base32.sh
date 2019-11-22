#!/bin/sh

#######################################
# Author:
#   shoma07
# LICENSE:
#   MIT
#######################################

# Base32 characters
CHARS=(a b c d e f g h i j k l m n o p q r s t u v w x y z 2 3 4 5 6 7)

#######################################
# Usage
# Returns:
#   None
#######################################
base32_usage () {
  echo "Usage: $0 [-h] <command> value"
  echo ""
  echo "  command:"
  echo "    encode        "
  echo "    decode        "
  echo ""
  echo "  options:"
  echo "    -h         help"
  exit 1
}

#######################################
# Base32 encode
# Globals:
#   CHARS
# Arguments:
#   String
# Returns:
#   String
#######################################
base32_encode () {
  if [ -p /dev/stdin ] && [ -z "${@}" ]; then args=$(cat -); else args=${@}; fi

  echo $(echo $(echo "$(echo "${args}" | fold -1 | while read c; do
    hex=($(printf "%b" ${c} | od -tx1 | head -n 1 | tr '[a-z]' '[A-Z]'))
    printf "%08d" $(echo "obase=2;ibase=16;$(echo ${hex[1]})" | bc)
  done)" | fold -5 | while read b; do
    b=${b}$(for (( i=0; i<((5-${#b})); i++ )); do printf "0"; done)
    d=$(echo "obase=10;ibase=2;${b}" | bc)
    for (( i=0; i<32; i++ )); do
      if [ ${i} -ne ${d} ]; then continue; fi

      printf "${CHARS[${i}]}"
    done
  done) | fold -8 | while read c; do
    printf "${c}$(for (( i=0; i<((8-${#c})); i++)); do printf "="; done)"
  done) | tr '[a-z]' '[A-Z]'
}

#######################################
# Base32 decode
# Globals:
#   CHARS
# Arguments:
#   String
# Returns:
#   String
#######################################
base32_decode () {
  if [ -p /dev/stdin ] && [ -z "${@}" ]; then args=$(cat -); else args=${@}; fi

  printf "%s\n" $(echo $(echo "${args}" | sed "s/=//g") | fold -8 | while read s; do
    echo $(echo "${s}" | fold -1 | while read c; do
      c=$(echo ${c} | tr '[A-Z]' '[a-z]')
      for (( i = 0; i < ${#CHARS[@]}; i++ )); do
        if [ "${CHARS[${i}]}" != "${c}" ]; then continue; fi

        printf "%05d" $(echo "obase=2;ibase=10;${i}" | bc)
        break
      done
    done) | fold -8 | while read b; do
      if [ ${#b} -lt 8 ]; then break; fi

      printf "\\\x%02X" "$(echo "obase=10;ibase=2;${b}" | bc)"
    done
  done)
}

command=${1}
shift
while getopts :h OPT
do
  case $OPT in
    h)  base32_usage
      ;;
    \?) base32_usage
      ;;
  esac
done
shift $((OPTIND - 1))

if [ "${command}" == "encode" ] || [ "${command}" == "decode" ]; then
  base32_${command} "${@}"
else
  base32_usage
fi
