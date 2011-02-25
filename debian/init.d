#! /bin/sh
#
# skeleton	example file to build /etc/init.d/ scripts.
#		This file should be used to construct scripts for /etc/init.d.
#
#		Written by Miquel van Smoorenburg <miquels@cistron.nl>.
#		Modified for Debian
#		by Ian Murdock <imurdock@gnu.ai.mit.edu>.
#               Further changes by Javier Fernandez-Sanguino <jfs@debian.org>
#
# Version:	@(#)skeleton  1.9  26-Feb-2001  miquels@cistron.nl
#

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/usr/bin/g5k-api
NAME=g5k-api
DESC=g5k-api

test -x $DAEMON || exit 0

LOGDIR=/var/log/g5k-api
PIDFILE=/var/run/$NAME.pid
DODTIME=5                   # Time to wait for the server to die, in seconds
                            # If this value is set too low you might not
                            # let some servers to die gracefully and
                            # 'restart' will not work

# Include g5k-api defaults if available
if [ -f /etc/default/g5k-api ] ; then
	. /etc/default/g5k-api
fi

set -e


running_pid()
{
    # Check if a given process status name matches a given name
    pid=$1
    name=$2
    [ -z "$pid" ] && return 1
    [ ! -d /proc/$pid ] &&  return 1
    cmd=`cat /proc/$pid/status | grep Name: | cut -f 2`
    # Is this the expected child?
    [ "$cmd" != "$name" ] &&  return 1
    return 0
}

running()
{
  # Check if the process is running looking at /proc
  # (works for all users)
    # No pidfile, probably no daemon present
    [ ! -f "$PIDFILE" ] && return 1
    # Obtain the pid
    pid=`cat $PIDFILE`
    running_pid $pid $NAME || return 1
    return 0
}

force_stop() {
# Forcefully kill the process
    [ ! -f "$PIDFILE" ] && return
    if running ; then
        kill -15 $pid
        # Is it really dead?
        [ -n "$DODTIME" ] && sleep "$DODTIME"s
        if running ; then
            kill -9 $pid
            [ -n "$DODTIME" ] && sleep "$DODTIME"s
            if running ; then
                echo "Cannot kill $NAME (pid=$pid)!"
                exit 1
            fi
        fi
    fi
    rm -f $PIDFILE
    return 0
}

case "$1" in
  start)
	echo -n "Starting $DESC: "
	if running ; then
	  echo "already running."
  else
  	$DAEMON $DAEMON_OPTS start
    if running ; then
        echo "OK."
    else
        echo "ERROR."
    fi
  fi
	;;
  stop)
	echo -n "Stopping $DESC: "
	$DAEMON $DAEMON_OPTS stop
	echo "OK."
	;;
  force-stop)
	echo -n "Forcefully stopping $DESC: "
    force_stop
    if ! running ; then
        echo "OK."
    else
        echo "ERROR."
    fi
	;;
  #reload)
	#
	#	If the daemon can reload its config files on the fly
	#	for example by sending it SIGHUP, do it here.
	#
	#	If the daemon responds to changes in its config file
	#	directly anyway, make this a do-nothing entry.
	#
	# echo "Reloading $DESC configuration files."
	# start-stop-daemon --stop --signal 1 --quiet --pidfile \
	#	/var/run/$NAME.pid --exec $DAEMON
  #;;
  force-reload)
	#
	#	If the "reload" option is implemented, move the "force-reload"
	#	option to the "reload" entry above. If not, "force-reload" is
	#	just the same as "restart" except that it does nothing if the
	#   daemon isn't already running.
	# check wether $DAEMON is running. If so, restart
	  if running ;  then
      $0 restart
    fi
	;;
  restart)
    echo "Restarting $DESC..."
    $0 stop && $0 start
	;;
  status)
    echo -n "$NAME is "
    if running ;  then
      echo "running."
    else
      echo "not running."
      exit 1
    fi
    ;;
  *)
	N=/etc/init.d/$NAME
	# echo "Usage: $N {start|stop|restart|reload|force-reload}" >&2
	echo "Usage: $N {start|stop|restart|force-reload|status|force-stop}" >&2
	exit 1
	;;
esac

exit 0
