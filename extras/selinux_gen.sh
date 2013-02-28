#!/bin/sh -e

DIRNAME=`dirname $0`
cd $DIRNAME
export NAME=$1
USAGE="$0 <policy_name> [ --update ]"
if [ `id -u` != 0 ]; then
  echo 'You must be root to run this script'
  exit 1
fi

if [ $# -eq 1 ]; then
  if [ "$2" = "--update" ] ; then
    time=`ls -l --time-style="+%x %X" $NAME.te | awk '{ printf "%s %s", $6, $7 }'`
    rules=`ausearch --start $time -m avc --raw -se $NAME`
    if [ x"$rules" != "x" ] ; then
      echo "Found avc's to update policy with"
      echo -e "$rules" | audit2allow -R
      echo "Do you want these changes added to policy [y/n]?"
      read ANS
      if [ "$ANS" = "y" -o "$ANS" = "Y" ] ; then
        echo "Updating policy"
        echo -e "$rules" | audit2allow -R >> ${NAME}.te
      else
        exit 0
      fi
    else
      echo "No new avcs found"
      exit 0
    fi
  else
	  echo -e $USAGE
	  exit 1
  fi
elif [ $# -ge 4 ] ; then
  echo -e $USAGE
  exit 1
fi

echo "Building and Loading Policy"
set -x
make -f /usr/share/selinux/devel/Makefile $NAME.pp || exit
/usr/sbin/semodule -i ${NAME}.pp

sepolicy manpage -p . -d httpd_${NAME}_script_t

pwd=$(pwd)
rpmbuild --define "_sourcedir ${pwd}" --define "_specdir ${pwd}" --define "_builddir ${pwd}" --define "_srcrpmdir ${pwd}" --define "_rpmdir ${pwd}" --define "_buildrootdir ${pwd}/.build"  -ba $NAME-selinux.spec
