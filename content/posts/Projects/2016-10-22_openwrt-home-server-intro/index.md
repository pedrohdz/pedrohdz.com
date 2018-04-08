Title: OpenWRT Home Server - Introduction
Modified: 2016-10-22
Tags: openwrt
Authors: Pedro F. H.
Summary: In this series, I detail my experiences in getting a home server setup on home Internet router using OpenWRT.
Series: OpenWRT Home Server


## Project summary

The goal of this project is to setup a simple home server running [OpenWRT][]
on a wireless router.  _OpenWRT_ is a slimmed down Linux distribution for
embedded devices.

Some of the reasons for pursuing this project on an old home Internet router
with [OpenWRT][] are:

  - Lower power requirements than running on an old laptop or computer.  The
    router I will be using, the [Netgear WNDR3800][], maxes out at 30 W.
  - Fanless to help keep down on the noise.
  - Runs fine at higher room temperatures.
  - _OpenWRT_ is an active open source project going back to 2004 and beyond.
    The number of home routers and embedded systems it will run on is near
    endless.
  - Long list of software packages already built and ready to be installed.
  - Frequently updated, with security fixes.


#### Initial goals:

  - Wireless access point, and firewall.  I am a little torn on running all
    these services on my firewall.  We'll see where this project takes us.
  - File server for use with [Kodi][] running on Amazon's [Fire TV Stick][]
  - Tangentially related.  Getting [Kodi][] running on a [Fire TV Stick][].
    "[Kodi][] is a free and open-source media player software application
    developed by the XBMC Foundation", from the *[Kodi entry on Wikipedia][]*.

#### Nice to haves:

  - Print server, potentially using [Samba][].
  - Scan server, if it is even possible.  [SANE][] seems like a potential
    solution.

## Details

### Netgear WNDR3800

The [Netgear WNDR3800][] made its debut back in 2011.  It might sounds a little
dated, but it with 128 GB or RAM, 16 GB flash, two dual band antennas, Gigabit
Ethernet ports and then some, it should be more than adequate for the job.

Note that even though I implemented the home server using the [Netgear
WNDR3800][], the majority of it is written to apply to other equipment as well.
The only exception being the [installing OpenWRT][] section.

The following summary was pulled from [OpenWRT's WNDR3800 wiki page].

|                   |Details                                                     |
|-------------------|------------------------------------------------------------|
|Name               |WNDR3800 - N600 Wireless Dual Band Gigabit Router - Premium Edition|
|Model              |WNDR3800 v1|
|CPU                |Atheros AR7161 rev 2 680MHz|
|Wireless Chipsets  |AR9220 + AR9223|
|RAM                |128 MB|
|Flash              |16 MB|
|2.4 GHz WiFi       |802.11 b/g/n|
|5.0 GHz WiFi       |802.11 a/n|
|Notes on wireless  |Simultaneous dual band (2.4 and 5 GHz) with dual-stream N.|
|Ethernet ports     |1 WAN + 4x LAN (Gigabit Ethernet)|
|USB 2.0 ports      |1|
|Serial             |Yes|
|JTag               |Yes|




[Kodi entry on Wikipedia]: https://en.wikipedia.org/wiki/Kodi_(software)
    (Quoted from Wikipedia)
[Samba]: https://www.samba.org/
    (Samba project's homepage)
[SANE]: http://www.sane-project.org/
    (Scanner Access Now Easy homepage)
[Fire TV Stick]: https://amzn.com/B00ZV9RDKK
    (Amazon's Fire TV Stick page)
[Kodi]: https://kodi.tv/
    (Kodi's homepage)
[Netgear WNDR3800]: https://www.netgear.com/support/product/WNDR3800
    (Netgear's WNDR3800 support page)
[OpenWRT's WNDR3800 wiki page]: https://wiki.openwrt.org/toh/netgear/wndr3800
    (OpenWRT's WNDR3800 wiki page)
[OpenWRT]: https://openwrt.org/
    (OpenWRT's project homepage)
[installing OpenWRT]: {filename}../2016-11-29_openwrt-home-server-installing-openwrt/index.md
