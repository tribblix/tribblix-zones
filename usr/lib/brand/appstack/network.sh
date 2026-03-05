#!/bin/ksh
#
# SPDX-License-Identifier: CDDL-1.0
#
# {{{ CDDL HEADER
#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source. A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#
# }}}
#
# Copyright 2026 Peter Tribble
#

#
# bring up networking inside an exclusive-ip zone
# this script should be copied into the appstack zone and
# launched from init
#

#
# bring up an interface
#
bring_up() {
    IFNAME="$1"
    if [ -n "${IFNAME}" ]; then
	/sbin/ifconfig $IFNAME plumb
    fi
    if [ -f "/etc/hostname.${IFNAME}" ]; then
	/sbin/ifconfig $IFNAME inet $(<"/etc/hostname.${IFNAME}") up
    fi
    if [ -f "/etc/hostname6.${IFNAME}" ]; then
	/sbin/ifconfig $IFNAME inet6 up
    fi
}

#
# networking requires certain daemons be up and running
#
env SMF_FMRI=svc/net/ip:d /sbin/dlmgmtd
env SMF_FMRI=svc/net/ip:d /lib/inet/ipmgmtd

#
# the expectation here is that create-zone has populated the
# hostname files for us
#
/bin/ls -1 /etc/hostname* 2>/dev/null | while read -r iface
do
    bring_up "${iface##*.}"
done

if [ -f /etc/defaultrouter ]; then
    /sbin/route add net default $(<"/etc/defaultrouter")
fi
