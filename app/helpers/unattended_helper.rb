module UnattendedHelper
  # outputs kickstart installation media based on the media type (NFS or URL)
  # it also convert the $arch string to the current host architecture

  def mediapath
    server, dir  = @host.media.path.split(":")
    dir.gsub!('$arch',@host.architecture.name)

    return server =~ /^(h|f)t*p$/ ? "url --url #{server+":"+dir}" : "nfs --server #{server} --dir #{dir}"
  end

  def preseed_server
    @host.media.path.match('^(\w+):\/\/((\w|\.)+)((\w|\/)+)$')[2]
  end

  #TODO: rethink of a more generic way
  def preseed_path
    @host.media.path.match('^(\w+):\/\/((\w|\.)+)((\w|\/)+)$')[4]
  end

  def yumrepo
    if @repo
      "--enablerepo #{repo}"
    end
  end

  def epel
    if @osver.to_i == 5 or 4
      "su -c 'rpm -Uvh http://download.fedora.redhat.com/pub/epel/#{@osver}/#{@arch}/epel-release-#{@host.os.to_version}.noarch.rpm'"
    else
      ""
    end
  end

  def ca_pubkey
    unless $settings[:CAPubKey].nil?
      "echo \"#{$settings[:CAPubKey]}\" >> /var/lib/puppet/ssl/certs/ca.pem
count=`grep -- \"--END\" /var/lib/puppet/ssl/certs/ca.pem|wc -l`
echo \"Updated the certificate chain. There are now $count certificates\""
    end
    return ""
  end

  def ks_console
    (@port and @baud) ? "console=ttyS#{@port},#{@baud}": ""
  end

  def grub_pass
    @grub ? "--md5pass=#{@host.root_pass}": ""
  end

  def root_pass
    @host.root_pass
  end

  def puppet_conf
"[main]
    vardir = /var/lib/puppet
    logdir = /var/log/puppet
    rundir = /var/run/puppet
    ssldir = \$vardir/ssl
    pluginsource = puppet://\$server/plugins
    environments = #{@host.environment}

[puppetd]
    factsync = true
    report = true
    ignoreschedules = true
    daemon = false
    certname = #{@host.name}
    environment = #{@host.environment}
    server = #{@host.puppetmaster}"
  end

  def puppet_init
    "#!/bin/bash
# chkconfig: - 98 02
#
# description: puppet client bootstrap
# processname: puppet
# config: /etc/puppet/puppet.conf


/usr/sbin/puppetd --config /etc/puppet/puppet.conf -o --ignoreschedules true --server=#{@host.puppetmaster} > /tmp/puppet.log 2>&1"
  end

  def handle_vmware
    "# Deal with vmware install here as it cannot be done under puppet
# The vmware configuration disconnects the puppetmaster and kernel modules need updating
if dmidecode | grep -qi VMware
then
	echo \"Installing vmware support services\"
	# This arranges for vmware-config-tools.pl to be run on first bootup,
	# after any new kernel but before the network has been initialised
	yum -t -y -e 0 #{yumrepo} install VMwareTools #{@osver == "5" ? "kernel-devel gcc" : ""}
	cat <<-\EOF >/etc/init.d/vmware-config-tools
	#!/bin/sh
	# Author:       Paul Kelly
	#
	# chkconfig: 2345 01 99
	# description:  Checks and configures vmware tools

	# Source function library.
	. /etc/init.d/functions

	# If the module exists then it must have been compiled aginst this kernel and should therefore load
	start() {
	    if [ ! -e /lib/modules/`uname -r`/misc/vmhgfs.#{@osver == "3" ? "o" : "ko"} ]
	    then
	        action $\"Configuring vmware tools: \" /usr/bin/vmware-config-tools.pl -d
	    fi
	    touch /var/lock/subsys/vmware-config-tools
	}

	stop() {
	    rm -f /var/lock/subsys/vmware-config-tools
	}
	# See how we were called.
	case \"$1\" in
	start)
	    start
	    ;;
	stop)
	    stop
	    ;;
	status)
	    if [ -e /var/lock/subsys/vmware-config-tools ]; then
	        echo $\"VMWare configuration has been checked.\"
			exit 1
	    else
	        echo $\"Vmware configuration has not been checked.\"
	    fi
	    ;;
	restart|reload)
	    stop
	    start
	    ;;
	*)
	    # do not advertise unreasonable commands that there is no reason
	    # to use with this device
	    echo $\"Usage: $0 {start|stop|status|restart|reload}\"
	    exit 1
	esac

	exit 0
	EOF
	chmod 755 /etc/init.d/vmware-config-tools
	chkconfig --add vmware-config-tools
fi
  "
  end
end
