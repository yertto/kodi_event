# kodi_event
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)

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


### Alternatives
| repo | [JSON-RPC API](https://kodi.wiki/view/JSON-RPC_API) | [Event Server](https://kodi.wiki/view/EventServer) | CLI | description |
| :--- | :--- | :--- | :--- | :--- |
| [kodi-remotecontrol](https://github.com/dmachard/kodi-remotecontrol#websocket-client) | 🚫 | :white_check_mark: | 🚫 | This is a Python remote control for Kodi with minimal but sufficient basic controls. This remote control acts as a WebSocket Gateway of the UDP Event Server API for more reactivity. |
| [kodi-control](https://github.com/KenKundert/kodi-control) |:white_check_mark: | 🚫 | 🚫 | Kodi Control can be used to control a running instance of Kodi from a terminal. You can use it to interactively control the app and the players by opening a terminal and typing individual characters to perform various actions |
| [xbmc-client](https://github.com/jcsaaddupuy/xbmc-client) | :white_check_mark: | 🚫 | :white_check_mark: | is a Kodi command line client, written in Python to control your Kodi instance through the JSON-RPC API |
| [kodi-cli](https://github.com/JavaWiz1/kodi-cli) | :white_check_mark: | 🚫 | :white_check_mark: | used from the command line to execute commands against a target Kodi host via the RPC interface defined at JSON-RPC API This provides a Kodi JSON-RPC client. All Kodi JSON methods can be called as methods to the KodiJSONClient instance. |
| [python-kodijson](https://github.com/jcsaaddupuy/python-kodijson) | :white_check_mark: | 🚫 | 🚫 | Simple python module that allow kodi control over JSON-RPC API |
| [kodijsonrpc](https://github.com/davgeo/kodijsonrpc) | :white_check_mark: | 🚫 | 🚫 | This provides a Kodi JSON-RPC client. All Kodi JSON methods can be called as methods to the KodiJSONClient instance. |
| [kodicontroller](https://github.com/davgeo/kodicontroller) | :white_check_mark: | 🚫 | 🚫 | This package provides an array of functions which can be used to control a Kodi instance. |
| [PyKodi](https://github.com/OnFreund/PyKodi) | :white_check_mark: | 🚫 | 🚫 | An async python interface for Kodi over JSON-RPC. This is mostly designed to integrate with HomeAssistant. If you have other needs, there might be better packages available. |
   


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
