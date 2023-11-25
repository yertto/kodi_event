#!/usr/bin/env shpec
# shellcheck disable=SC1091,SC2016
source shpecs/shpec_helper.sh

describe "kodi_event_packet"
  describe "ACTION"
    matches_expected_packet \
      'pt=ACTION kodi_event_packet "ActivateWindow(VideoBookmarks)"' \
      ACTION/VideoBookmarks

    # TODO - find out all the actions which are `ACTION=BUTTON`
    describe "BUTTON"
      matches_expected_packet \
        'pt=ACTION action=BUTTON kodi_event_packet CreateBookmark' \
        ACTION/BUTTON/CreateBookmark
    end_
  end_

  describe "BUTTON"
    matches_expected_packet \
      'pt=BUTTON kodi_event_packet escape' \
      BUTTON/escape

    matches_expected_packet \
      'map_name=XG pt=BUTTON kodi_event_packet dpadright' \
      BUTTON/XG-dpadright

    matches_expected_packet \
      'map_name=R1 pt=BUTTON kodi_event_packet info' \
      BUTTON/R1-info

    describe "code"
      # Don't really know where to find codes
      describe "11 - select"
        matches_expected_packet \
          'code=11 kodi_event_packet' \
          BUTTON/code/11
      end_
    end_
  end_

  # Not sure this actually works - how do you test it?
  describe "BROADCAST"
    matches_expected_packet \
      'BROADCAST=255.255.255.255 kodi_event_packet' \
      BROADCAST
  end_

  describe "BYE"
    matches_expected_packet \
      'pt=BYE kodi_event_packet' \
      BYE
  end_

  # Not sure this actually works - how do you test it?
  # The logs for this packet say:
  # `ES: Got Unknown Packet`
  describe "DEBUG"
    matches_expected_packet \
      'pt=DEBUG kodi_event_packet' \
      DEBUG
  end_

  describe "HELO"
    describe "device_name"
      matches_expected_packet \
        'pt=HELO kodi_event_packet foo' \
        HELO/device_name
    end_

    describe "icon"
      matches_expected_packet \
        'pt=HELO icon=shpecs/support/ha.png kodi_event_packet' \
        HELO/icon
    end_
  end_

  describe "LOG"
    matches_expected_packet \
      'pt=LOG kodi_event_packet "$(printf "X%.0s" {1..10})"' \
      LOG/10chars

    matches_expected_packet \
      'pt=LOG kodi_event_packet "$(printf "Y%.0s" {1..900})"' \
      LOG/900chars

    # NB. A message size of 1000 flows over into a second packet,
    # *and* the second packet is 10 bytes long
    # (which is a good test because `\x0a` is also a line feed character as,
    # depending on how it's done, can get swallowed up when building up strings.)
    matches_expected_packet \
      'pt=LOG kodi_event_packet "$(printf "Z%.0s" {1..1000})"' \
      LOG/1000chars
  end_

  describe "MOUSE"
    matches_expected_packet \
      'pt=MOUSE kodi_event_packet 32535 32535' \
      MOUSE/50%_50%

    matches_expected_packet \
      'pt=MOUSE kodi_event_packet 16267 32535' \
      MOUSE/25%_50%
  end_

  describe "NOTIFICATION"
    matches_expected_packet \
      'pt=notification kodi_event_packet "$(printf "X%.0s" {1..10})"' \
      NOTIFICATION/10chars

    matches_expected_packet \
      'pt=notification title="A Title" kodi_event_packet "$(printf "X%.0s" {1..10})"' \
      NOTIFICATION/10chars_with_title

    describe "icon"
      matches_expected_packet \
        'pt=notification icon=shpecs/support/ha.png kodi_event_packet "$(printf "I%.0s" {1..10})"' \
        NOTIFICATION/icon
    end_
  end_

  # Not sure this actually works - how do you test it?
  describe "PING"
    matches_expected_packet \
      'pt=ping kodi_event_packet' \
      PING
  end_
end_
