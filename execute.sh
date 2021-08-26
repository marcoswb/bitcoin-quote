#!/usr/bin/env bash

# Colors for printf
CIANO='\033[1;36m'
NO_COLOR='\033[0m'
MAGENTA='\033[1;35m'

# Message -h
USE_MESSAGE="
Use: $(basename "$0") UPDATE_TIME_SECONDS NUMBER_OF_REQUESTS
OPTIONS:
    -h, --help - Help page
"
# Lynx installed?
[ ! -x "$(which lynx)" ] && printf "${CIANO}We need to install ${MAGENTA}Lynx${CIANO}, please, type your password:${NO_COLOR}\n" && sudo dnf install lynx 1> /dev/null 2>&1 -y

API_MERCADO_BITCOIN="https://www.mercadobitcoin.net/api/BTC/ticker/"
INFORMATIONS_DESCRIPTION=(
  "Highest unit price of the last 24 hours: "
  "Lowest unit price of the last 24 hours: "
  "Quantity traded in the last 24 hours: "
  "Unit price of the last negotiation: "
  "Highest bid offer price in the last 24 hours: "
  "Lowest offer price for the last 24 hours: "
  "Unit price of opening trading on the day: "
  "Date: "
)
UPDATE_TIME=${1:-2}
NUMBER_OF_REQUESTS=${2:-5}

formatDate () {
  date -d "@${1}" +%d/%m/%Y # Format to dd/mm/yyyy
}

getData () {
  [ $1 -eq 7 ] && echo -e "${MAGENTA}${INFORMATIONS_DESCRIPTION[$1]}${CIANO}$(formatDate ${ARRAY_JSON_MERCADO_BITCOIN[$1]})\n--" && return
  echo -e "${MAGENTA}${INFORMATIONS_DESCRIPTION[$1]}${CIANO}${ARRAY_JSON_MERCADO_BITCOIN[$1]}"
}

listData () {
local counter=0
local counter_2=0

while [[ $counter -lt $NUMBER_OF_REQUESTS ]]; do
  while [[ $counter_2 -lt ${#ARRAY_JSON_MERCADO_BITCOIN[@]} ]]; do
    getData $counter_2
    counter_2=$(($counter_2+1))
  done
  sleep $UPDATE_TIME
  counter=$(($counter+1))
  counter_2=0
done
}

if test -n "$1"; then
  case "$1" in
    -h|--help)    printf "$USE_MESSAGE\n"  && exit 0 ;;
  esac
fi

read -r -a ARRAY_JSON_MERCADO_BITCOIN <<< "$(lynx -source $API_MERCADO_BITCOIN | sed 's/[^0-9.,]//g' | sed 's/,/ /g')"

listData