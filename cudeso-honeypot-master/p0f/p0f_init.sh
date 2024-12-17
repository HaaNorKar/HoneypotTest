### BEGIN INIT INFO
# Provides: p0f
# Required-Start: $all
# Required-Stop:
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: p0f
# Description: p0f
# Passive OS Fingerprinting
### END INIT INFO

# Copied from
#  https://raw.githubusercontent.com/zam89/maduu/master/init/p0f

# Using the lsb functions to perform the operations.
. /lib/lsb/init-functions
# Process name ( For display )
NAME=p0f
DAEMON=/usr/sbin/p0f
PIDFILE=/var/run/p0f.pid
SOCK=/var/run/p0f.sock
CHROOT_USER=dionaea  # same user/group
NETWORK_IF=any

PARAMETERS="-u $CHROOT_USER -i $NETWORK_IF -Q $SOCK -q -l -d -o /var/log/p0f.log"

# If the daemon is not there, then exit.
test -x $DAEMON || exit 5

case $1 in
  start)
  # Checked the PID file exists and check the actual status of process
  if [ -e $PIDFILE ]; then
    status_of_proc -p $PIDFILE $DAEMON "$NAME process" && status="0" || status="$?"
    # If the status is SUCCESS then don't need to start again.
    if [ $status = "0" ]; then
    exit # Exit
    fi
  fi
  # Start the daemon.
  log_daemon_msg "Starting" "$NAME"
  # Start the daemon with the help of start-stop-daemon
  # Log the message appropriately
  if start-stop-daemon --start --quiet --oknodo --pidfile $PIDFILE --exec $DAEMON -- $PARAMETERS; then
    PID=`pidof -s p0f`
    if [ $PID ] ; then
      echo $PID >$PIDFILE
    fi
    log_end_msg 0
  else
    log_end_msg 1
  fi
  sudo chown $CHROOT_USER:$CHROOT_USER $SOCK
  ;;
  stop)
  # Stop the daemon.
  if [ -e $PIDFILE ]; then
    status_of_proc -p $PIDFILE $DAEMON "Stoppping $NAME" && status="0" || status="$?"
    if [ "$status" = 0 ]; then
      start-stop-daemon --stop --quiet --oknodo --pidfile $PIDFILE
      /bin/rm -rf $PIDFILE
      /bin/rm $SOCK
    fi
  else
    log_daemon_msg "$NAME is not running..."
    log_end_msg 0
  fi
  ;;
  restart)
  # Restart the daemon.
  $0 stop && sleep 2 && $0 start
  ;;
  status)
  # Check the status of the process.
  if [ -e $PIDFILE ]; then
    status_of_proc -p $PIDFILE $DAEMON "$NAME process" && exit 0 || exit $?
  else
    log_daemon_msg "$NAME is not running..."
    log_end_msg 0
  fi
  ;;
  *)
  # For invalid arguments, print the usage message.
  echo "Usage: $0 {start|stop|restart|status}"
  exit 2
  ;;
esac
