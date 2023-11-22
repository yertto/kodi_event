#!/usr/bin/env zsh
# NB. this is a partial bash re-implementation of
#  * https://github.com/xbmc/xbmc/blob/5ec39d778c6b62e3a229f6a20ebd4e4aa96ecead/tools/EventClients/lib/python/xbmcclient.py

# Usage:
#   *                                   kodi_packet.zsh
#   * DEBUG=true  PT=BUTTON map_name=KB kodi_packet.zsh left
#   *                       map_name=XG kodi_packet.zsh dpadleft
#   * title=test  PT=NOTIFICATION       kodi_packet.zsh hi there
#   * title=test  PT=NOTIFICATION       kodi_packet.zsh hi there
#   * icon=ha.png PT=NOTIFICATION       kodi_packet.zsh hi there  # not working yet
#   *             PT=MOUSE              kodi_packet.zsh 255 255

EVENT_SERVER_HOST=${EVENT_SERVER_HOST:-localhost}
EVENT_SERVER_PORT=${EVENT_SERVER_PORT:-9777}

SIGNATURE="XBMC"
VERSION_MAJOR=${VERSION_MAJOR:-2}
VERSION_MINOR=${VERSION_MINOR:-0}

MAX_PACKET_SIZE=1024
HEADER_SIZE=32
MAX_PAYLOAD_SIZE=$((MAX_PACKET_SIZE - HEADER_SIZE)) # 992

        PT_HELO=1
         PT_BYE=2
      PT_BUTTON=3
       PT_MOUSE=4
        PT_PING=5
   PT_BROADCAST=6
PT_NOTIFICATION=7
        PT_BLOB=8
         PT_LOG=9
      PT_ACTION=10
       PT_DEBUG=255


  BT_USE_NAME=$((1<<0)) # 0x01
      BT_DOWN=$((1<<1)) # 0x02
        BT_UP=$((1<<2)) # 0x04
BT_USE_AMOUNT=$((1<<3)) # 0x08
     BT_QUEUE=$((1<<4)) # 0x10
 BT_NO_REPEAT=$((1<<5)) # 0x20
      BT_VKEY=$((1<<6)) # 0x40
      BT_AXIS=$((1<<7)) # 0x80
BT_AXISSINGLE=$((1<<8)) # 0x100

ICON_NONE=0
 ICON_JPG=1
 ICON_PNG=2
 ICON_GIF=3

ACTION_EXECBUILTIN=$((1<<0)) # 0x01
     ACTION_BUTTON=$((1<<1)) # 0x02  (although it _never_ get's used)

MS_ABSOLUTE=1

signature() {
  echo -n $SIGNATURE
}

unsigned_char() {
  echo -n "\x$(printf "%x" "$1")"
}

unsigned_short() {
  unsigned_char $(($1 / (1<<8)))
  unsigned_char $(($1 % (1<<8)))
}

unsigned_long() {
  unsigned_short $(($1 / (1<<16)))
  unsigned_short $(($1 % (1<<16)))
}

format_string() {
  echo -n "$*\x0"
}

uid() {
  echo -n "${uid:-$(date '+%s')}"
}

reserved() {
  # repeat 10 do unsigned_char 0; done
  echo -n "\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0"
}

# TODO - make this work
icon_type() {
  local ref
  icon_ext=$(echo "${icon##*.}" | tr '[:lower:]' '[:upper:]')
  case $icon_ext in
    JPG|JPEG) ref="ICON_JPG"         ;;
    PNG|GIF ) ref="ICON_${icon_ext}" ;;
    *       ) ref="ICON_NONE"        ;;
  esac

  echo -n ${(P)ref}
}

header() { local packet_size="$1"
  signature
  unsigned_char  $VERSION_MAJOR
  unsigned_char  $VERSION_MINOR
  unsigned_short $packettype
  unsigned_long  ${seq:-1}
  unsigned_long  ${maxseq:-1}
  unsigned_short $packet_size
  unsigned_long  $(uid)
  reserved
}

packets() { local payloads="$(cat)"
  local ref="PT_${PT}"
  packettype="${(P)ref}"

  maxseq=$((${#payloads} / MAX_PAYLOAD_SIZE + 1))

# fifo=$(mkfifo -m rw)

  for seq in {1..$maxseq}; do
    buffer_file=$(mktemp)

    packet="${payloads[$(((seq - 1) * MAX_PAYLOAD_SIZE + 1)), $(((seq - 1) * MAX_PAYLOAD_SIZE + MAX_PAYLOAD_SIZE))]}"
    if [ $seq -gt 1 ]; then
      packettype=$PT_BLOB
    fi

    {
      packettype=$packettype seq=$seq maxseq=$maxseq header "${#packet}"
      echo -ne "$packet"
    } > $buffer_file

# $fifo <  $buffer_file
    cat "$buffer_file"
    rm "$buffer_file"
  done

# cat $fifo

#  for packet in $(fold -w5 <<< "${payloads}"); do
#    >&2 echo "packet=[$packet]"
#    #printf "$(packettype=$((blob ? PT_BLOB : pt)) header "${#packet}")${packet}"
#    #blob=true
#  done
}

packetACTION() { local value="${1:-}"
  local ref="ACTION_${ACTION:-EXECBUILTIN}"
  actiontype="${(P)ref}"

  unsigned_char "$actiontype"
  format_string "$value"
}

packetBUTTON() { local button_name="${1:-}"
  # map_name - https://github.com/xbmc/xbmc/blob/5ec39d778c6b62e3a229f6a20ebd4e4aa96ecead/tools/EventClients/lib/python/xbmcclient.py#L333-L342
  #  * KB - https://github.com/xbmc/xbmc/blob/5ec39d778c6b62e3a229f6a20ebd4e4aa96ecead/system/keymaps/keyboard.xml
  #  * XG - https://github.com/xbmc/xbmc/blob/5ec39d778c6b62e3a229f6a20ebd4e4aa96ecead/system/keymaps/gamepad.xml
  #  * R1 - https://github.com/xbmc/xbmc/blob/5ec39d778c6b62e3a229f6a20ebd4e4aa96ecead/system/keymaps/remote.xml
  #  * R2 - ???
  #  * LI:Antec_Veris_RM200 - https://github.com/xbmc/xbmc/blob/5ec39d778c6b62e3a229f6a20ebd4e4aa96ecead/system/Lircmap.xml#L293C18-L337

  local flags=0

  #map_name=${map_name:-KB}

  code=${code:-0}
  # If no code given then use a default map_name & button_name
  if [[ $code == "0" ]]; then
    flags=$((flags + $BT_USE_NAME))
    map_name="${map_name:-KB}"
    button_name="${button_name:-enter}"
  else
    if ! [[ "$code" =~ '^[0-9]+$' ]]; then
      # if its a char then convert that to the ord(char)
      code="$(printf '%d' "'$code")"
    fi
    # code=$((code + 61440))  # ie. 0xf000 ... but why?
    button_name=""
  fi

  down=${down:-1}
  if [ $down -eq 1 ]; then
    flags=$((flags + BT_DOWN))
  else
    flags=$((flags + BT_UP))
  fi

  amount=${amount:-0}
  if [ $amount -gt 0 ]; then
    flags=$((flags + BT_USE_AMOUNT))
  fi

  repeat=${repeat:-1}
  if [ $repeat -lt 2 ]; then
    flags=$((flags + BT_NO_REPEAT))
  fi

  queue=${queue:-1}
  if [ $queue -ne 0 ]; then
    flags=$((flags + BT_QUEUE))
  fi

  axis=${axis:-0}
  case $axis in
    2) flags=$((flags + $BT_AXIS))       ;;
    1) flags=$((flags + $BT_AXISSINGLE)) ;;
  esac

  unsigned_short $code
  unsigned_short $flags
  unsigned_short $amount
  format_string  ${map_name:-}
  format_string  ${button_name:-}
}

packetBROADCAST() {
  :
}

packetBYE() {
  :
}

packetDEBUG() {
  :
}

packetHELO() { local device_name="${*:-${device_name:-device name}}"
  reserved=0
  format_string  "${device_name[0,128]}"
  unsigned_char  $(icon_type)
  unsigned_short $reserved
  unsigned_long  $reserved
  unsigned_long  $reserved
  if [ -e "$icon" ]; then
    cat "$icon"
  fi
}

packetLOG() { local value="${*:-test}"
  unsigned_char ${loglevel:-0}
  format_string "$value"
}

packetMOUSE() { local x="${1:-0}" y="${2:-0}"
  unsigned_char $MS_ABSOLUTE
  unsigned_short $x
  unsigned_short $y
}

packetNOTIFICATION() { local value="${*:-test}"
  title="${title:-$(basename $ZSH_ARGZERO)}"

  reserved=0
  format_string "$title"
  format_string "$value"
  unsigned_char $(icon_type)
  unsigned_long $reserved

  if [ -e "$icon" ]; then
    cat "$icon"
  fi
}

packetPING() {
  :
}


# hack needed to use DEBUG from yaml which uses True/False instead of true/false
True() { true; }
False() { false; }


export PT="${PT:-BUTTON}"
"packet${PT}" "$@" | packets
