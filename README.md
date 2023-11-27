# kodi_event
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)

Bash script to compose and send [Event Server](https://kodi.wiki/view/EventServer) packets to a [Kodi](https://kodi.tv).

Its only dependency is the [xxd](https://manpages.org/xxd) command.
(which is usually packaged with [vim-common](https://packages.debian.org/sid/vim-common) so hopefully is already installed)


(NB. This requires Kodi to be confirgured to [allow remote control from applications on other systems](https://kodi.wiki/view/Settings/Services/Control#Allow_remote_control_from_applications_on_other_systems))

## Getting Started
### Installation:
```
git clone git@github.com:yertto/event_client.git ~/Code/event_client
export PATH="$HOME/Code/event_client/bin:$PATH"
```



### Alternatives
| repo | [JSON-RPC API](https://kodi.wiki/view/JSON-RPC_API) | [Event Server](https://kodi.wiki/view/EventServer) | CLI | language | description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| [kodi-remotecontrol](https://github.com/dmachard/kodi-remotecontrol#websocket-client) | 🚫 | :white_check_mark: | 🚫 | python | This is a Python remote control for Kodi with minimal but sufficient basic controls. This remote control acts as a WebSocket Gateway of the UDP Event Server API for more reactivity. |
| [kodi-control](https://github.com/KenKundert/kodi-control) |:white_check_mark: | 🚫 | :white_check_mark: | python | Kodi Control can be used to control a running instance of Kodi from a terminal. You can use it to interactively control the app and the players by opening a terminal and typing individual characters to perform various actions |
| [kodi-cli](https://github.com/JavaWiz1/kodi-cli) | :white_check_mark: | 🚫 | :white_check_mark: | python | used from the command line to execute commands against a target Kodi host via the RPC interface defined at JSON-RPC API This provides a Kodi JSON-RPC client. All Kodi JSON methods can be called as methods to the KodiJSONClient instance. |
| [python-kodijson](https://github.com/jcsaaddupuy/python-kodijson) | :white_check_mark: | 🚫 | 🚫 | python | Simple python module that allow kodi control over JSON-RPC API |
| [xbmc-client](https://github.com/jcsaaddupuy/xbmc-client) | :white_check_mark: | 🚫 | :white_check_mark: | python | is a Kodi command line client, written in Python to control your Kodi instance through the JSON-RPC API ( |
| [kodijsonrpc](https://github.com/davgeo/kodijsonrpc) | :white_check_mark: | 🚫 | 🚫 | python | This provides a Kodi JSON-RPC client. All Kodi JSON methods can be called as methods to the KodiJSONClient instance. |
| [kodicontroller](https://github.com/davgeo/kodicontroller) | :white_check_mark: | 🚫 | 🚫 | python | This package provides an array of functions which can be used to control a Kodi instance. |
| [PyKodi](https://github.com/OnFreund/PyKodi) | :white_check_mark: | 🚫 | 🚫 | python | An async python interface for Kodi over JSON-RPC. This is mostly designed to integrate with HomeAssistant. If you have other needs, there might be better packages available. |
   


## Motivation

* [Home Assistant - Kodi](https://www.home-assistant.io/integrations/kodi) ([View Source](https://github.com/home-assistant/core/tree/dev/homeassistant/components/kodi)) is a Home Assistant integration to control a [Kodi](https://kodi.tv) multimedia system.

However I wanted to use Kodi's [Event Server](https://kodi.wiki/view/EventServer) so I could use button events to drive the UI.
In particular I want to send `Left` and `Right` button events so I can use the [Skip Steps](https://kodi.wiki/view/Skip_steps) to incrementally skip.

I only found one alternatives that would connect to the Event Server.
However to run in my Home Assistant it need to be able to run with the *very* minimal resources used by [BusyBox](https://busybox.net)
> BusyBox combines tiny versions of many common UNIX utilities into a single small executable. It provides replacements for most of the utilities you usually find in GNU fileutils, shellutils, etc. The utilities in BusyBox generally have fewer options than their full-featured GNU cousins; however, the options that are included provide the expected functionality and behave very much like their GNU counterparts. BusyBox provides a fairly complete environment for any small or embedded system.

Which means I needed something that would run at a bare minimum.
(ie. in my case `bash` & BusyBox's version of `xxd`)


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

Or run using the generic `kodi_event` command setting a different packet type (pt):
 * `            pt=BUTTON       kodi_event escape`
   * along with other button names for the default `map_name=KB` found in [keyboard.xml](https://github.com/xbmc/xbmc/blob/5ec39d778c6b62e3a229f6a20ebd4e4aa96ecead/system/keymaps/keyboard.xml)
 * `map_name=XG pt=BUTTON       kodi-button dpadleft`
    * along with other button names for `map_name=XG` found in [gamepad.xml](https://github.com/xbmc/xbmc/blob/5ec39d778c6b62e3a229f6a20ebd4e4aa96ecead/system/keymaps/gamepad.xml)
 * `map_name=R1 pt=BUTTON       kodi-button mymusic`
    * along with other button names for `map_name=R1` found in [remote.xml](https://github.com/xbmc/xbmc/blob/5ec39d778c6b62e3a229f6a20ebd4e4aa96ecead/system/keymaps/remote.xml)
 * `code=11     pt=BUTTON       kodi-button`
    * will send the button with code `"11"` 
 * `            pt=NOTIFICATION kodi_event hello world`
 * `            pt=LOG          kodi_event hello logs`
   
Or there's also convenience scripts that pass in the `pt` type to `kodi_event`:
 * `kodi-helo                    ` # equavilent to `pt=HELO         kodi_event            `
 * `kodi-button       escape     ` # equavilent to `pt=BUTTON       kodi_event escape     `
 * `kodi-notification hello world` # equavilent to `pt=NOTIFICATION kodi_event hello world`
 * `kodi-log          hello logs ` # equavilent to `pt=LOG          kodi_event hello logs `
 * `kodi-ping                    ` # equavilent to `pt=PING         kodi_event            `
 * `kodi-bye                     ` # equavilent to `pt=BYE          kodi_event            `
   
Nb. these require a `EVENT_SERVER_HOST` env var pointing at the Kodi instance.

(Or `BROADCAST=255.255.255.255` to broadcast to _all_ Kodi instances.)
