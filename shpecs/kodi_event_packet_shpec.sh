#!/usr/bin/env shpec
# shellcheck disable=SC1091,SC2016
source shpecs/shpec_helper.sh

describe "kodi_event_packet.zsh"
  describe "ACTION"
    matches_expected_packet \
      'PT=ACTION kodi_event_packet.zsh "ActivateWindow(VideoBookmarks)"' \
      ACTION/VideoBookmarks

    # TODO - find out all the actions which are `ACTION=BUTTON`
    describe "BUTTON"
      matches_expected_packet \
        'PT=ACTION ACTION=BUTTON kodi_event_packet.zsh CreateBookmark' \
        ACTION/BUTTON/CreateBookmark
    end_
  end_

  describe "BUTTON"
    matches_expected_packet \
      'PT=BUTTON kodi_event_packet.zsh escape' \
      BUTTON/escape

    matches_expected_packet \
      'map_name=XG PT=BUTTON kodi_event_packet.zsh dpadright' \
      BUTTON/XG-dpadright

    matches_expected_packet \
      'map_name=R1 PT=BUTTON kodi_event_packet.zsh info' \
      BUTTON/R1-info

    describe "code"
      # Don't really know where to find codes
      describe "11 - select"
        matches_expected_packet \
          'code=11 kodi_event_packet.zsh' \
          BUTTON/code/11
      end_
    end_
  end_

  # Not sure this actually works - how do you test it?
  describe "BROADCAST"
    matches_expected_packet \
      'PT=BROADCAST kodi_event_packet.zsh' \
      BROADCAST
  end_

  # Not sure this actually works - how do you test it?
  describe "BYE"
    matches_expected_packet \
      'PT=BYE kodi_event_packet.zsh' \
      BYE
  end_

  # Not sure this actually works - how do you test it?
  describe "DEBUG"
    matches_expected_packet \
      'PT=DEBUG kodi_event_packet.zsh' \
      DEBUG
  end_

  # Not sure this actually works - how do you test it?
  describe "HELO"
    matches_expected_packet \
      'PT=HELO kodi_event_packet.zsh' \
      HELO
  end_

  describe "LOG"
    matches_expected_packet \
      'PT=LOG kodi_event_packet.zsh "$(printf "X%.0s" {1..10})"' \
      LOG/10chars

    matches_expected_packet \
      'PT=LOG kodi_event_packet.zsh "$(printf "Y%.0s" {1..900})"' \
      LOG/900chars

    # NB. A message size of 1000 flows over into a second packet,
    # *and* the second packet is 10 bytes long
    # (which is a good test because `\x0a` is also a line feed character as,
    # depending on how it's done, can get swallowed up when building up strings.)
    matches_expected_packet \
      'PT=LOG kodi_event_packet.zsh "$(printf "Z%.0s" {1..1000})"' \
      LOG/1000chars
  end_

  describe "MOUSE"
    matches_expected_packet \
      'PT=MOUSE kodi_event_packet.zsh 32535 32535' \
      MOUSE/50%_50%

    matches_expected_packet \
      'PT=MOUSE kodi_event_packet.zsh 16267 32535' \
      MOUSE/25%_50%
  end_

  describe "NOTIFICATION"
    matches_expected_packet \
      'PT=NOTIFICATION kodi_event_packet.zsh "$(printf "X%.0s" {1..10})"' \
      NOTIFICATION/10chars

    matches_expected_packet \
      'title="A Title" PT=NOTIFICATION kodi_event_packet.zsh "$(printf "X%.0s" {1..10})"' \
      NOTIFICATION/10chars_with_title
  end_

  # Not sure this actually works - how do you test it?
  describe "PING"
    matches_expected_packet \
      'PT=PING kodi_event_packet.zsh' \
      PING
  end_
end_
