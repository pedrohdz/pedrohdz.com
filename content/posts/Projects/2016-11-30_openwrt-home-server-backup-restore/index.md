Title: OpenWRT Home Server - Backup and Restore
Modified: 2016-11-30
Tags: openwrt
Authors: Pedro F. H.
Summary: How to backup and restore an OpenWRT router.
Series: OpenWRT Home Server


## Overview

After completing [OpenWRT Home Server - Installation and Configuration][] we
want to make sure that we can backup and restore our _OpenWRT_ router with
ease.  It will allow us to continue through the series with a bit of
confidence, giving us more freedom to experiment.

This how to is useful to anyone wanting to backup an _OpenWRT_ router, even if
you are not following along with this series.

## Details

The following should be backed up on all systems:

  1. [Installed packages].
  2. [Configuration files].


### Installed packages

Here we back up a list of installed packages.  The credit goes to [Upgrade
OpenWRT and reinstalling packages][] for the idea on how to handle this.

#### Backing up list of installed packages

Make sure to run this before baking up the configuration files, covered in a
section below.

```bash
root@homesrv:~# opkg list-installed > /etc/config/installed.packages
```

#### Restoring installed packages

The router will need access to the Internet before being able to install
packages.  Assuming that there is a path out:

```bash
root@homesrv:~# opkg update
root@homesrv:~# opkg install \
   $(cut -f 1 -d ' ' < /etc/config/installed.packages)
```


### Configuration files

_OpenWRT_ uses `sysupgrade` to backup configuration files.  [sysupgrade][] is
used for **both** _LuCI_ web admin and command line backups, so it is important
to configure it correctly.

***WARNING***: The _OpenWRT_ `sysupgrade` backup system has to be configured
correctly or else files will be missed during backup.  Throughout this series,
I will do my best to point out when `sysupgrade` needed to be informed of a new
configuration file to backup.  In the end it is your responsibility to keep
`sysupgrade` configured correctly.

#### Configuring sysupgrade

`sysupgrade` determines which configuration files to backup by:

  1. Using a list of modified configuration files provided by [opkg][], this
     list can be viewed by using the `opkg list-changed-conffiles` command.
  2. Reading the list of file names in `/etc/sysupgrade.conf`, an example can
     be found here: [sysupgrade.conf][].

On the router, comb through the output of `opkg list-changed-conffiles` and
check for missing entries:

```bash
$ ssh root@192.168.1.1
root@homesrv:~# opkg list-changed-conffiles | sort -u
```

If you completed [OpenWRT Home Server - Installation and Configuration][], you
might notice that `/etc/dropbear/authorized_keys` is missing.
`/etc/config/installed.packages` from above should be added as well.  Update
the `sysupgrade` configuration with `vi /etc/sysupgrade.conf` and add it.  The
contents of `/etc/sysupgrade.conf` should look something like:

```
## This file contains files and directories that should
## be preserved during an upgrade.

# /etc/example.conf
# /etc/openvpn/
/etc/sysupgrade.conf
/etc/config/installed.packages
```

_OpenWRT_ comes with a minimalistic `vi` application that is part of
[BusyBox][].


#### Backing up configuration files

Create the backup in the `/tmp/` directory.  `/tmp/` is actually an in memory
file system (RAM).  Backing up to anywhere else would likely fill up the
already limited space on the router, as well as increase the wear on the flash.

```bash
root@homesrv:~# sysupgrade -v --create-backup \
    /tmp/backup-$(cat /proc/sys/kernel/hostname)-$(date +%F).tgz
```

Next you should confirm that backup exists and contains the expected files:

```bash
root@homesrv:~# ls -l /tmp/backup-*-$(date +%F).tgz
root@homesrv:~# tar -zvtf /tmp/backup-*-$(date +%F).tgz
```

Copy the backup file off of the router and put it somewhere safe, `scp` to your
workstation might be a good option.  The remove the backup file once it has
been copied off of the router to free up space:

```bash
root@homesrv:~# rm /tmp/backup-*-$(date +%F).tgz
```

#### Restoring configuration files

`scp` the backup file into the `/tmp/` directory on the router, then:

```bash
root@OpenWrt~# sysupgrade -v --restore-backup /tmp/backup-*.tgz
root@OpenWrt~# reboot
```


### Workflows

Some general workflows on how to backup and restore a router with _OpenWRT_.

#### Backup workflow


  1. [Backup list of installed packages][].
  2. [Backup configuration files][].
  3. Copy the backup file off of the router and put it in a safe place.
  4. Delete the backup file from `/tmp/` on the router.

#### Restore workflow

For a simple, configuration only restore:

  1. Copy the backup file to the `/tmp/` director on the router.
  2. [Restore installed packages][].
  3. Reboot the router.

If you lost everything, configuration files and installed packages (this
happens after a factory reset):

  1. First get the router connected to the Internet again.  You can  untar the
     backup file on your workstation and pull the information you need from
     there.
  2. Once connected to the Internet, copy `installed.packages` to `/tmp/` on
     the router.  The [Restore installed packages][].
  3. Copy the backup file to the `/tmp/` director on the router.
  4. [Restore configuration files][].
  5. Reboot the router.


### Backup and restore through the web interface

And, of course, backups and restores can be performed through the
administrative web interface.  The page can be found through the _System ->
Backup / Flash Firmware_ menu.

Backups through the web admin site do not include a list of installed packages,
that will still have to be done manually.  `/etc/sysupgrade.conf` still has to
be updates to pick up missing files, as described in [Configuring
sysupgrade][].


### Advanced backup and restore

For those that want to do a full backup of the flash, read [OpenWRT Generic
Backup][].


## Further reading:

  - OpenWrt documentation:
    - [sysupgrade.conf][]
    - [sysupgrade][]
    - [OpenWRT Generic Backup][]
    - [opkg][]
  - [Upgrade OpenWRT and reinstalling packages][]
  - [BusyBox][] - BusyBox homepage.



[//]: # (--- OpenWrt documentation  ---)
[sysupgrade.conf]: https://wiki.openwrt.org/doc/howto/notuci.config#etcsysupgradeconf
  (OpenWrt documentation)
[sysupgrade]: https://wiki.openwrt.org/doc/techref/sysupgrade
  (OpenWrt documentation)
[OpenWRT Generic Backup]: https://wiki.openwrt.org/doc/howto/generic.backup
  (OpenWrt documentation)
[opkg]: https://wiki.openwrt.org/doc/techref/opkg
  (OpenWrt documentation)
[Upgrade OpenWRT and reinstalling packages]: http://techfindings.one/archives/1696
    (Blog post from TechFindings)

[//]: # (--- Other links ---)
[BusyBox]: https://www.busybox.net/
    (BusyBox homepage)

[//]: # (--- Internal links ---)
[OpenWRT Home Server - Introduction]: {filename}../2016-10-22_openwrt-home-server-intro/index.md
    (Internal link)
[OpenWRT Home Server - Installation and Configuration]: {filename}../2016-11-29_openwrt-home-server-installing-openwrt/index.md
    (Internal link)
[Backup list of installed packages]: #backing-up-list-of-installed-packages
    (In page link to section)
[Restore installed packages]: #restoring-installed-packages
    (In page link to section)
[Backup configuration files]: #backing-up-configuration-files
    (In page link to section)
[Restore configuration files]: #restoring-configuration-files
    (In page link to section)
[Configuring sysupgrade]: #configuring-sysupgrade
    (In page link to section)
[Configuration files]: #configuration-files
    (In page link to section)
[Installed packages]: #installed-packages
    (In page link to section)

