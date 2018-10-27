#!/usr/bin/with-contenv sh

# check a refresh token exists
if [ -f /root/.oonfig/refresh_token ]; then
  echo "Found onedrive refresh token..."
else
  echo
  echo "-------------------------------------"
  echo "ONEDRIVE LOGIN REQUIRED"
  echo "-------------------------------------"
  echo "To use this container you must authorize the OneDrive Client."

  if [ -t 0 ] ; then
    echo "-------------------------------------"
    echo
  else
    echo
    echo "Please re-start start the container in interactive mode using the -it flag:"
    echo
    echo "docker run -it -v /local/config/path:/config -v /local/documents/path:/documents oznu/onedrive"
    echo
    echo "Once authorized you can re-create container with interactive mode disabled."
    echo "-------------------------------------"
    echo
    exit 1
  fi

fi

if [ -f $HOME/onedrive.conf ]
then
  cp -f $HOME/.config/onedrive.conf $HOME/.config/onedrive_backup.conf
fi

if [ -f /usr/local/etc/my_onedrive.conf ]
then
  cp -f /usr/local/etc/my_onedrive.conf $HOME/.config/onedrive.conf
fi

# turn on or off verbose logging
if [ "$DEBUG" = "1" ]; then
  VERBOSE=true
else
  VERBOSE=false
fi

echo "Starting onedrive client..."

# s6-setuidgid abc onedrive --monitor --confdir=/config --syncdir=/documents --verbose=${VERBOSE}

usr/local/bin/onedrive -m

