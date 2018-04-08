Title: OpenWRT Home Server - Installation and Configuration
Modified: 2016-11-29
Tags: openwrt
Authors: Pedro F. H.
Summary: A guide on installing, configuring, and securing OpenWRT on a Netgear WNDR3800.  Even though this is written specifically for the WNDR3800, many sections of the documentation can be used on other devices.
Series: OpenWRT Home Server


## Overview

Even though this guide is geared towards the [Netgear WNDR3800][], it is still
a good starting point for getting familiar with installing, configuring and
securing [OpenWRT][].  At the beginning of each section, I will call out
whether or not it is _WNDR3800_ specific.  The [Securing the Router][] section
down below should be of particular interest to all, irrespective of hardware.
All the subsequent titles in this series apply to all _OpenWRT_ installations
in general.

For those with other routers, the [OpenWRT Newcomer's Guide][] is a great place
to start.

If you haven't done so already, you might want to take a quick look at [OpenWRT
Home Server - Introduction][].

This document was originally intended to be notes to myself.  Reminders on what
I did, why I did them, and how.  With that in mind, note that this guide is
command line heavy.  It is a personal preference.  _OpenWRT_ does come with
[LuCI][] installed, a configuration/administration web site, for virtually all
supported devices.  For an introduction to _LuCI_ take a look at the [OpenWRT
Newcomer's Guide][]

_**WARNING:**_ There is always a chance of bricking your router.  Make sure to
read up and educate yourself on what you are doing before proceeding.


#### Goals

  - Installing _OpenWRT_ on a _WNDR3800_ router.
  - Securing _OpenWRT_ routers.
  - Basic network configuration.

#### Non-Goals

We will not be installing any secondary services such as FTP, Samba, SFTP, or
similar.  Those will be left for future titles in this series.


## Details

### Installing OpenWRT

_**This section is WNDR3800 specific.  Jump to [Securing the Router][] if you
would like.**_

This section is based on the [WNDR3800 installation wiki][] page.

Two methods of installing _OpenWRT_ on the _WNDR3800_ are covered below:

  1. Through the original firmware administrative web page.
  2. Failsafe mode.  This is my personal favorite when I don't care about
     wiping out the previous configuration.  Comes in handy when you brick your
     _WNDR3800_.  I haven't tried it, but it might be possible to flash a stock
     _WNDR3800_ this way.

Before you proceed to either of the following sections, locate and download the
`squashfs-factory` version from the [latest ar71xx generic flash images][]
page.  At the time of this writing, it is
[openwrt-15.05.1-ar71xx-generic-wndr3800-squashfs-factory.img][].

The difference between the `factory` and `sysupgrade` is that the latter will
not overwrite the _OpenWRT_ configuration information on the flash.  The
`factory` image contains a baseline _OpenWRT_ configuration required for first
time boot.


#### Through the original firmware administrative web page

So it's been a long time since I have had to do install on a stock _WNDR3800_,
so just use this section as a general reference,  Best thing to do is read the
[OEM easy installation][] section of _OpenWRT WNDR3800_ wiki page.

After acquiring the flash image:

  1. Connect to the administrative web site on the device, typically
     [http://192.168.1.1/](http://192.168.1.1/).
  2. Log in.  _(Hope you saved the admin password somewhere)_
  3. Navigate to the _Administration_ page.
  4. Proceed with selecting the image file you downloaded, and continue with
     flashing the device.
  5. _**Do not**_ unplug the device once the process has started.
  6. Sit back and wait a while and keep waiting until you can `telnet
     192.168.1.1`.

Proceed to the [Securing the Router](#securing-the-router) section down below.


#### Failsafe mode installation

This sections is based on the [recovery flash in failsafe mode][] section of
the _OpenWRT WNDR3800_ wiki page.

It is likely a good idea to use the `factory` image if you are using failsafe
mode to perform the installation.  Use `sysupgrade` if you are feeling
adventurous.

Before you begin, set up two terminal session on your workstation:

  1. First terminal to run `ping 192.168.1.1`, *after* rebooting the router.
     Just have this ready to go, do not starting pinging until after the router
     has rebooted.
  2. Second with `tftp` configured and ready to go.

Pining in the first terminal session is used to determine when the router has
finished booting into failsafe mode and is ready to have the image uploaded.

In the second terminal session, setup `tftp` as follows:

```bash
$ tftp
tftp> verbose
tftp> trace
tftp> rexmt 1
tftp> binary
```

Leave it open and fetch the _WNDR3800_ router.  Next:

  1. Configure your system with a static IP address, setting it at
     `192.168.1.2` and a subnet mask 255.255.255.0.
  2. Make sure that the power button on the back of the _WNDR3800_ is in the
     upper, off possition. The plug it into its power supply.  Keep the
     _WNDR3800_ powered off.
  3. Use an Ethernet cable to connect the workstation to one of the _WNDR3800_
     orange LAN ports, *not* the yellow port labeled _Internet_.
  4. Press down the _Restore Factory Settings_ button on the bottom of the
     _WNDR3800_ using a tooth pick, paper clip, or something similar and
     continue pressing it while turning on the router using the power button.
  5. Start the `ping 192.168.1.1` command on the first terminal session.  You
     should see `Request timeout` repeating.  **Continue holding down the reset
     button.**
  6. Wait about 60 seconds.
  7. Once the pings start returning, release the reset button.
  8. Return to the _tftp terminal session_ and enter:

         tftp> connect 192.168.1.1
         tftp> put openwrt-15.05.1-ar71xx-generic-wndr3800-squashfs-factory.img
         tftp> quit

  9. The upload should take a few seconds then the _WNDR3800_ will reboot
     itself.
  10. Look back at the ping output and wait until the router starts bouncing
      back responces.
  11. You can stop pinging.


Proceed to the [Securing the Router](#securing-the-router) section down below.


### Securing the Router

**This section applies to all _OpenWRT_ installations, not just _WNDR3800_**.

The `root` user has no password set on initial boot.  `telnet` will just drop a
user straight into a shell prompt with _root_ access.

In this section we will:

  1. Upload an SSH public key for accessing the system once the SSH server is
     started.
  2. Configure and start the SSH server, [Dropbear][].
  3. Shutdown telnet, permanently for security reasons.
  4. Set the `root` password.


#### Upload the public SSH key

First upload the `SSH` public key that will be used for accessing the router.
Taking advantage of the fact that `telnet` starts up a _root_ shell on the router,
use the following command to upload `~/.ssh/id_rsa.pub` to
`/etc/dropbear/authorized_keys` on the _OpenWRT_ system.  Give the command
about 10 seconds to complete on its own.  Do not interact with the `telnet`
session at all.  It acts like a minimal `expect` script.  It will terminate the
`telnet` session when it is done.:

```bash
$ { sleep 5; \
        echo "echo $(cat ~/.ssh/id_rsa.pub) | cat > /etc/dropbear/authorized_keys"; \
        sleep 5; \
        echo "exit"; } | telnet 192.168.1.1
```

Substitute `~/.ssh/id_rsa.pub` with the preferred SSH public key.

Make sure to `telnet` onto the router and confirm that
`/etc/dropbear/authorized_keys` was copied correctly.

#### Configure and start the SSH server

```bash
$ telnet 192.168.1.1
root@OpenWrt:~# uci set dropbear.@dropbear[0].RootPasswordAuth=off
root@OpenWrt:~# uci set dropbear.@dropbear[0].PasswordAuth=off
root@OpenWrt:~# uci commit dropbear
root@OpenWrt:~# /etc/init.d/dropbear restart
```

#### Disable telnet

```bash
root@OpenWrt:~# /etc/init.d/telnet disable
root@OpenWrt:~# /etc/init.d/telnet stop
```

The last command should have terminated your `telnet` session and logged you
out.

#### Set the root password

Use a long and complicated password:

```bash
$ ssh root@192.168.1.1
root@OpenWrt:~# passwd
```

That `passwd` command will prompt you to enter your new password.


### Basic Configuration

**This section applies to all _OpenWRT_ installations, not just _WNDR3800_**.

#### UCI overview

If you are not already familiar with the `uci` command that we have been using
so far, it stands for _Unified Configuration Interface_.  Per the
documentation:

> It is a small utility written in C (a shell script-wrapper is available as
> well) and is intended to centralize the whole configuration of a device
> running OpenWrt.

`uci` interacts with the [UCI configuration files][] located in `/etc/config`.

As an example take a look at the [Dropbear UCI configuration][] documentation,
then at `/etc/config/dropbear` on the _OpenWRT_ system.

It is worth taking a few minutes and looking over the documentation really
quick to get a general idea of what is going on.


#### Baseline network configuration

Next we want to configure the router with an IP address of our choosing, not
`192.168.1.1`, as well as a new hostname.

For this example we are using `homesrv` as the hostname, and `192.168.3.1` as
the IP address.  Change it as needed.

```bash
root@OpenWrt:~# uci set system.@system[0].hostname=homesrv
root@OpenWrt:~# uci commit system
root@OpenWrt:~# /etc/init.d/system reload
root@homesrv:~# uci set network.lan.ipaddr=192.168.3.1
root@homesrv:~# uci set network.lan.netmask=255.255.255.0
root@homesrv:~# uci commit network
root@homesrv:~# reboot
```


#### Wireless access to the WNDR3800

Things will likely vary from router model to router model so this section is
intended for the _WNDR3800_.  It is still worth reviewing to get familiar with
how to configure the network settings from the command line.

If you are using something other than a _WNDR3800_ best thing to do is to use
the web interface _LuCI_.  At this point it should be accessible via
[http://192.168.3.1/](http://192.168.3.1/) using the `root` credentials.  Once
logged in, go to _Network -> Wifi_ then press the _Edit_ button next to the
wireless radio you wish to configure.  Make sure to press the _Save & Apply_
button once you are done.

On a _WNDR3800_, the same can be done from the command line.  Make sure to
`CHANGE_THE_PASSWORD`, and rename the network if you would like, it is named
`homesrv` here.

First `ssh` onto the router:

```bash
$ ssh root@192.168.3.1
```

Next we want to get rid of the anonymous `wifi-iface` sections of the
`wireless` configuration to make it easier to manage from the command line.

_OpenWRT_ usually come preconfigured with a WiFi interface entry per radio.
The _WNDR3800_ has two radios, so two WiFi interface entries.  You can see
these entries in the `/etc/config/wireless` file on the router, or by executing
`uci show wireless`.  If you execute the previous command you will find the
following two entries:

```
wireless.@wifi-iface[0]=wifi-iface
wireless.@wifi-iface[1]=wifi-iface
```

These are called _anonymous sections_ per the [File syntax section of the UCI
documentation][].  They appear as arrays when querying through `uci` and can be
a nuisance to manage.  We will delete the two _anonymous sections_ and replace
them with named versions.  First we delete:

```bash
root@homesrv:~# uci delete wireless.@wifi-iface[1]
root@homesrv:~# uci delete wireless.@wifi-iface[0]
```

Next create a new named `wifi-iface` section called `homesrv`.  This will
contain the configuration for the new access point we are creating, with the
_SSID_ of `homesrv`.  Remember to change the password from
`CHANGE_THE_PASSWORD` to something else:

```bash
root@homesrv:~# uci set wireless.homesrv=wifi-iface
root@homesrv:~# uci set wireless.homesrv.device=radio0
root@homesrv:~# uci set wireless.homesrv.mode=ap
root@homesrv:~# uci set wireless.homesrv.ssid=homesrv
root@homesrv:~# uci set wireless.homesrv.encryption=psk2+tkip+ccmp
root@homesrv:~# uci set wireless.homesrv.key='CHANGE_THE_PASSWORD'
root@homesrv:~# uci set wireless.homesrv.network=lan
```

Configure the radio we are using, `radio0` in this case, and enable it:

```bash
root@homesrv:~# uci set wireless.radio0.country=US
root@homesrv:~# uci set wireless.radio0.txpower=29
root@homesrv:~# uci set wireless.radio0.disabled=0
```

Commit the changes and reload the network configuration:

```bash
root@homesrv:~# uci commit wireless
root@homesrv:~# /etc/init.d/network reload
```

The new access point should be available.


#### Connecting to the Internet

As with the previous section, this one is _WNDR3800_ centric, but with
information that may be useful to all.

For now, I am bouncing off of an existing wireless access point.  The
following is specific to my configuration, but should help in starting to get
an understanding of what is going on if you are not already familiar.

The easiest thing to do for new comers is to use the _LuCI_ web interface via
[http://192.168.3.1/](http://192.168.3.1/) using the `root` credentials.  Once
logged in go to _Network -> Wifi_ and press the _Scan_ button to find the
wireless access point to connect to.

Another option is to connect via the WAN Ethernet port.  Use the _Network ->
Interfaces_ menu item, find the _WAN_ interface and press the _Edit_ button
next to it.  There are a variety of options including: _PPPoE_, _DHCP client_,
among others.  Which to use completely depends on how you connect to the
Internet and it is out of scope for this document.

In my particular case, I will be connecting through an existing wireless access
point.  This should work through the rest of this series, allowing me to
experiment without accidentally taking out my Internet access.

First configure the `wwan` `interface` to use _DHCP_:

```bash
root@homesrv:~# uci set network.wwan=interface
root@homesrv:~# uci set network.wwan.proto=dhcp
root@homesrv:~# uci commit network
```

A single radio can have more than one `wifi-iface` configuration associated
with it.  In this case we will be using `radio0` to both server our access
point, and as a client to another existing access point to gain access to the
internet.

```bash
root@homesrv:~# uci set wireless.upstream=wifi-iface
root@homesrv:~# uci set wireless.upstream.device=radio0
root@homesrv:~# uci set wireless.upstream.ssid=AP_NAME
root@homesrv:~# uci set wireless.upstream.mode=sta
root@homesrv:~# uci set wireless.upstream.encryption=psk2
root@homesrv:~# uci set wireless.upstream.key=AP_PASSWORD
root@homesrv:~# uci set wireless.upstream.network=wwan
```

Commit the changes and reload the network configuration:

```bash
root@homesrv:~# uci commit wireless
root@homesrv:~# /etc/init.d/network reload
```

#### Final notes on configuration

For more information on the _UCI_ configuration options modified above, refer
to:

  - [UCI configuration files][] - Full listing of all the configuration files.
  - [Network configuration][] - "This configuration file is responsible for
    defining switch VLANs, interface configurations and network routes".
  - [Wireless configuration][] - "The wireless UCI configuration is located in
    `/etc/config/wireless`"
  - [System configuration][] - "The system configuration contains basic
    settings for the whole router. Larger subsystems such as the network
    configuration, the DHCP and DNS server, and similar, have their own
    configuration file."


### Revisiting security

**This section applies to all _OpenWRT_ installations, not just _WNDR3800_**.

Sending the `root` password in the clear without SSL/TLS just seems like a bad
idea.  Here we add SSL/TLS to _LuCI_ administrative web interface.

In this section we introduce the [OPKG Package Manager][].  As described in the
documentation:

  > The opkg utility (an ipkg fork) is a lightweight package manager used to
  > download and install OpenWrt packages from local package repositories or ones
  > located in the Internet.


Install the necessary packages, configure with redirecting port `80` traffic to
`443`, and restart:

```bash
root@homesrv:~# opkg update
root@homesrv:~# opkg install px5g uhttpd-mod-tls
root@homesrv:~# uci set uhttpd.main.listen_http=192.168.3.1:80
root@homesrv:~# uci set uhttpd.main.listen_https='192.168.3.1:443'
root@homesrv:~# uci set uhttpd.main.redirect_https='1'
root@homesrv:~# uci set uhttpd.px5g.bits='2048'
root@homesrv:~# uci commit uhttpd
root@homesrv:~# /etc/init.d/uhttpd restart
```

The `px5g` package is responsible for generating a self signed certificate.

If you want to take extra precaution, setup the _uhttpd_ to only accept
connections on localhost, then use _SSH_ port forwarding to connect to _LuCI_.
This would help make it more difficult for someone to brute force the `root`
password via the web interface.


## Wrap up

At this point you should have a router with _OpenWRT_ installed, and ready to
set up a small home server.


## Further Reading

  - [OpenWRT][] - OpenWRT's project homepage.
  - [OpenWRT Newcomer's Guide][] - Minimal set of instructions to get OpenWRT installed.
  - [Devices supported by OpenWRT][] - List of devices suported by OpenWRT.
  - [OpenWRT documentation][] - [LuCI][] - LuCI Technical Reference.
  - [OPKG Package Manager][] - Package Manager documentation.
  - [UCI][] - Unified Configuration Interface - Technical Reference.
  - [UCI configuration files][] - UCI configuration file documentation.
  - [Dropbear UCI configuration][] - Dropbear UCI configuration options.



[//]: # (--- WNDR3800 links ---)
[Netgear WNDR3800]: https://www.netgear.com/support/product/WNDR3800
    (Netgear's WNDR3800 support page)
[OpenWRT's WNDR3800 wiki page]: https://wiki.openwrt.org/toh/netgear/wndr3800
    (OpenWRT's WNDR3800 wiki page)
[WNDR3800 installation wiki]: https://wiki.openwrt.org/toh/netgear/wndr3800#installation
    (Installation section of the OpenWRT WNDR3800 wiki page)
[OEM easy installation]: https://wiki.openwrt.org/toh/netgear/wndr3800#oem_easy_installation
    (OpenWRT stock WNDR3800 installation guide)
[recovery flash in failsafe mode]: https://wiki.openwrt.org/toh/netgear/wndr3800#recovery_flash_in_failsafe_mode
    (OpenWRT WNDR3800 failsafe installation guide)
[latest ar71xx generic flash images]: https://downloads.openwrt.org/latest/ar71xx/generic/
    (Download directory containing latest ar71xx generic flash images)
[openwrt-15.05.1-ar71xx-generic-wndr3800-squashfs-factory.img]: https://downloads.openwrt.org/latest/ar71xx/generic/openwrt-15.05.1-ar71xx-generic-wndr3800-squashfs-factory.img

[//]: # (--- OpenWRT links ---)
[OpenWRT]: https://openwrt.org/
    (OpenWRT's project homepage)
[Devices supported by OpenWRT]: https://wiki.openwrt.org/toh/start
    (List of devices suported by OpenWRT)
[OpenWRT Newcomer's Guide]: https://wiki.openwrt.org/doc/guide-newcomer
    (Minimal set of instructions to get OpenWRT installed)
[OpenWRT documentation]: https://wiki.openwrt.org/doc/start
[LuCI]: https://wiki.openwrt.org/doc/techref/luci
    (LuCI Technical Reference)
[UCI]: https://wiki.openwrt.org/doc/techref/uci
    (Unified Configuration Interface - Technical Reference)
[UCI configuration files]: https://wiki.openwrt.org/doc/uci
    (UCI configuration file documentation)
[File syntax section of the UCI documentation]: https://wiki.openwrt.org/doc/uci
    (UCI configuration file documentation)
[Dropbear UCI configuration]: https://wiki.openwrt.org/doc/uci/dropbear
    (Dropbear UCI configuration options)
[Network configuration]: https://wiki.openwrt.org/doc/uci/network
    (UCI configuration file documentation)
[Wireless configuration]: https://wiki.openwrt.org/doc/uci/wireless
    (UCI configuration file documentation)
[System configuration]: https://wiki.openwrt.org/doc/uci/system
    (UCI configuration file documentation)
[OPKG Package Manager]: https://wiki.openwrt.org/doc/techref/opkg
    (Package Manager documentation)


[//]: # (--- Other links ---)
[Dropbear]: https://matt.ucc.asn.au/dropbear/dropbear.html
    (Dropbear SSH homepage)

[//]: # (--- Internal links ---)
[OpenWRT Home Server - Introduction]: {filename}../2016-10-22_openwrt-home-server-intro/index.md
[Securing the Router]: #securing-the-router
    (Jump to section)
