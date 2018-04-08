Title: OpenWRT Home Server - Selecting a router
Modified: 2016-10-29
Tags: openwrt
Authors: Pedro F. H.
Summary: A guide on selecting a router to install OpenWrt on.
Series: OpenWRT Home Server


## Recommended hardware

The [Devices supported by OpenWRT with full details][] page is a great place to
start looking for hardware.

Here are some hardware requirements to start with.  _Minimum_ configuration
would be a good place to start for simple experimentations, but you will
quickly start seeing issues when running services like [Samba][].

|                   |Minimum         |Recommended                             |
|-------------------|----------------|----------------------------------------|
|RAM                |32 MB           |>=128 MB|
|Flash              |8  MB           |>=16 MB|
|WiFi               |2.4 GHz 802.11 b/g| 2.4 GHz 802.11 b/g/n, 5.0 GHz WiFi|
|USB ports          |1 USB 2.0       |>1 USB 2.0 or 3.0|
|Ethernet ports     |1 WAN + 4x LAN  |Gigabit Ethernet|
|Serial             |-               |Yes (or JTag)|
|JTag               |-               |Yes (or Serial)|

_JTag_, and _serial_ ports come in handy when recovering a bricked device.  I
have never had to use either after 10+ years of experimenting with routers
(_knock on wood_), but it is good to have just for in case.

Things to keep in mind while searching:

  - Use the _white fields_ in the column headers to help narrow down your
    search.  Here is a [filtered list][] containing currently available
    routers, supported in 15.05, 128 MB of RAM as an example.  Experiment with
    the filters.
  - Flash is critical.  It dictates how many packages can be installed on a
    device.
  - There is a good chance you cab still be able to get items that are listed
    as _Discontinued_.  In some cases you might be able to get them at batter
    prices.  Just search around on the web.
  - _Supported Current Rel_ should be _OpenWrt_ version _15.05_ or higher.
    This might not be accurate, look at the devices wiki page and the
    [OpenWrt Downloads][] to get a more accurate account of it is supported.
  - Look at the OpenWrt hardware wiki page for the devices.  Look for detailed
    installation instructions, how to recover bricked devices, how well it is
    documented.  This page is very important when it comes to device specific
    questions that *will* come up.  [OpenWRT's WNDR3800 wiki page][] is an
    example of a good one.
  - Take a look at the [OpenWrt forum][].  Here is the [WNDR3800 forum page][]
    as an example.  Note that the entries are listed oldest to last, which is a
    bit confusing and gives a false sense of inactivity.


## Netgear WNDR3800

I am using the [Netgear WNDR3800][].  The [Netgear WNDR3800][] made its debut
back in 2011.  It might sounds a little dated, but it with 128 GB or RAM, 16 GB
flash, two dual band antennas, Gigabit Ethernet ports and then some, it should
be more than adequate for the job.

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




[//]: # (--- WNDR3800 links ---)
[Netgear WNDR3800]: https://www.netgear.com/support/product/WNDR3800
    (Netgear's WNDR3800 support page)
[OpenWRT's WNDR3800 wiki page]: https://wiki.openwrt.org/toh/netgear/wndr3800
    (OpenWRT's WNDR3800 wiki page)
[WNDR3800 forum page]: https://forum.openwrt.org/viewtopic.php?id=28392,%20https://forum.openwrt.org/viewtopic.php?id=50914

[//]: # (--- OpenWRT links ---)
[Devices supported by OpenWRT]: https://wiki.openwrt.org/toh/start
    (List of devices suported by OpenWRT)
[Devices supported by OpenWRT with full details]: https://wiki.openwrt.org/toh/views/toh_extended_all
    (List of devices suported by OpenWRT with full details)
[OpenWrt Downloads]: https://downloads.openwrt.org/
[filtered list]: https://wiki.openwrt.org/toh/views/toh_extended_all?dataflt%5BAvailability*~%5D=Available&dataflt%5BSupported+Current+Rel*~%5D=15.05&dataflt%5BRAM+MB*~%5D=128
[OpenWrt Forum]: https://forum.openwrt.org/index.php
[OpenWRT]: https://openwrt.org/
    (OpenWRT's project homepage)

[//]: # (--- Other links ---)
[Samba]: https://www.samba.org/
    (Samba project's homepage)
