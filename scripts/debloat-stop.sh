#!/bin/sh
# Stop LG telemetry/ad daemons and keep the on-demand ones from starting (RAM-only; a reboot restores them unless run from init.d).
export PATH=/usr/bin:/usr/sbin:/bin:/sbin:$PATH
L=/media/developer/cleanyourtv
for s in remotelogger service-logger contentminer nudge rdxd uploadd; do systemctl stop $s.service 2>&1 | sed "s/^/$s: /"; done
# luna dynamic services: bind a do-nothing stub over the binary so ls-hubd cannot start them
printf '#!/bin/sh\nexit 0\n' > $L/stub-noop; chmod +x $L/stub-noop
for b in acr2 admanager sportsalarm adoverlay-service; do
  [ -e /usr/sbin/$b ] || continue
  grep -q " /usr/sbin/$b " /proc/mounts || mount --bind $L/stub-noop /usr/sbin/$b
  pkill -9 -f "^/usr/sbin/$b"
done
# ad servers (resolved + verified as LG ad endpoints); marker lets debloat-undo.sh remove them
h=$(grep -v "# cleanyourtv-debloat" /etc/hosts)
case "$h" in *localhost*) ;; *) h=$(grep -v "# cleanyourtv-debloat" $L/backup/hosts.orig 2>/dev/null) ;; esac
{ [ -n "$h" ] && printf '%s\n' "$h"; cat <<'H'
127.0.0.1 eic.ads.lgtvcommon.com nl.ad.lgsmartad.com nl.info.lgsmartad.com rdl.lgtvcommon.com # cleanyourtv-debloat
::1 eic.ads.lgtvcommon.com nl.ad.lgsmartad.com nl.info.lgsmartad.com rdl.lgtvcommon.com # cleanyourtv-debloat
H
} > /etc/hosts
