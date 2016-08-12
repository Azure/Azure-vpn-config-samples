#!/bin/bash
# Credit to Endre Szabó https://end.re/2015-01-06_vti-tunnel-interface-with-strongswan.html

set -o nounset
set -o errexit

VTI_IF="vti${PLUTO_UNIQUEID}"

case "${PLUTO_VERB}" in
    up-client)
        ip tunnel add "${VTI_IF}" local "${PLUTO_ME}" remote "${PLUTO_PEER}" mode vti \
            okey "${PLUTO_MARK_OUT%%/*}" ikey "${PLUTO_MARK_IN%%/*}"
        ip link set "${VTI_IF}" up
        ip route add 10.12.0.0/16 dev "${VTI_IF}"
        ip route add 10.11.0.0/16 dev "${VTI_IF}"
        sysctl -w "net.ipv4.conf.${VTI_IF}.disable_policy=1"
        ;;
    down-client)
        ip tunnel del "${VTI_IF}"
        ;;
esac