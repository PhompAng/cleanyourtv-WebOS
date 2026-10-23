#!/bin/sh
# Undo debloat-stop.sh: restart the systemd daemons, remove the stubs and the hosts lines (dynamic services start on demand again).
export PATH=/usr/bin:/usr/sbin:/bin:/sbin:$PATH
for b in acr2 admanager sportsalarm adoverlay-service; do
  for m in $(awk -v b="/usr/sbin/$b" 'substr($2,length($2)-length(b)+1)==b {print $2}' /proc/mounts | sort -r); do umount $m 2>/dev/null; done
done
for s in remotelogger service-logger contentminer nudge rdxd uploadd; do systemctl start $s.service; done
h=$(grep -v "# cleanyourtv-debloat" /etc/hosts)
case "$h" in *localhost*) ;; *) h=$(cat /media/developer/cleanyourtv/backup/hosts.orig 2>/dev/null) ;; esac
[ -n "$h" ] && printf '%s\n' "$h" > /etc/hosts
