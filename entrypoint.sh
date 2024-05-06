#!/bin/sh

# re-entrant script to support automatically switching to an unprivileged user
# that matches the ownership of the RUN_WORKDIR (see below)

set -e

RUN_USER=pdk
RUN_WORKDIR="${PWD}"

[ -z "${UID}" ] && UID=$(id -u)
[ -z "${GID}" ] && GID=$(id -g)

[ "$UID" -ne 0 ] && RUNNING_NON_ROOT=1

# check if required path is mounted
# check for deprecated /root volume
if grep -sq " /root " < /proc/mounts ; then
  [ -z "$ENTRYPOINT_RELOAD" ] && echo >&2 "warning: the /root workdir is deprecated, use /workspace instead."
  RUN_WORKDIR="/root"
elif ! grep -sq " ${RUN_WORKDIR} " < /proc/mounts ; then
  echo >&2 "error: ${RUN_WORKDIR} is not mounted in the container." ; exit 1
fi

create_user() {
  if [ "$1" -gt 0 ] ; then
    if [ "$2" -gt 0 ] ; then
      su - -c "groupadd -g $2 $RUN_USER" 2>/dev/null || true
    fi
    su - -c "useradd -d /cache -u $1 -g $2 $RUN_USER ; chown $RUN_USER: /cache ; passwd -d $RUN_USER >/dev/null"
  fi
}

# skip if re-running under newly created user
if [ -z "$ENTRYPOINT_RELOAD" ] ; then
  if [ -z "$RUNNING_NON_ROOT" ] ;  then
    UID=$(stat -c '%u' "$RUN_WORKDIR")
    GID=$(stat -c '%g' "$RUN_WORKDIR")
    [ "$UID" -eq 0 ] && RUN_USER="root"
  fi
  create_user "$UID" "$GID"
  # re-run with new user
  exec su - $RUN_USER -c "cd $RUN_WORKDIR ; ENTRYPOINT_RELOAD=1 $0 $*"
  exit
fi

# sanity check supported volumes
for volume in ${RUN_WORKDIR} /cache ; do
  if [ ! -w "$volume" ] ; then
    echo >&2 "error: unable to write to ${volume}. Ensure permissions are correct on the host." ; exit 1
  fi
  if ! find "$volume/." -maxdepth 1 -name '.' \( -uid "$UID" -a -perm -u+rw \) -o \( -group "$GID" -a -perm -g+rw \) -exec true {} + ; then
    echo >&2 "warning: pdk may not function properly with the user/group ownership or permissions on ${volume}."
  fi
done

# recommend cache path is mounted
if ! grep -sq " /cache " < /proc/mounts ; then
  echo >&2 "mount a volume to /cache in the container to improve performance."
fi

export PATH="${PATH}:/opt/puppetlabs/pdk/private/git/bin"
export PDK_DISABLE_ANALYTICS=true
export LANG=C.UTF-8

exec /opt/puppetlabs/pdk/bin/pdk "$@"
