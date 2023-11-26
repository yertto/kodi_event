# kodi_event
[![Conventional Commits][conventional-commits-image]][conventional-commits-url]

Bash shell scripts to compose and send Kodi Event packets to a Kodi Server.

## Getting Started
### Installation:
```
git clone git@github.com:yertto/event_client.git ~/Code/event_client
export PATH="$HOME/Code/event_client/bin:$PATH"
```


#### Requirements:
 * [bash](https://www.gnu.org/software/bash/)
 * [xxd](https://manpages.org/xxd) (usually packaged with [vim-common](https://packages.debian.org/sid/vim-common) so hopefully already installed)


## Motivation

* [Home Assistant - Kodi](https://www.home-assistant.io/integrations/kodi) ([View Source](https://github.com/home-assistant/core/tree/dev/homeassistant/components/kodi)) is a Home Assistant integration to control a [Kodi](https://kodi.tv) multimedia system.
* [xbmc-client](https://github.com/jcsaaddupuy/xbmc-client) is a Kodi command line client, written in Python to control your Kodi instance through the [JSON-RPC API](https://kodi.wiki/view/JSON-RPC_API)

However I wanted to use Kodi's [Event Server](https://kodi.wiki/view/EventServer) so I could use button events to drive the UI.
In particular I want to send `Left` and `Right` button events so I can use the [Skip Steps](https://kodi.wiki/view/Skip_steps) to incrementally skip.


## Testing
The tests can be run with:
 * `make test`

These tests make "golden test" assertions against pre-created binary packets.
(that have been manually tested against Kodi v20.1.0)
ie. by running:
 * `cat shpecs/support/NOTIFICATION/10chars_with_title.bin | EVENT_SERVER_HOST=$kodi_host kodi_event_send`
 * `cat shpecs/support/BUTTON/R1-info.bin | EVENT_SERVER_HOST=$kodi_host kodi_event_send`

Or run interactively using:
 * `kodi_event-test_menu`
