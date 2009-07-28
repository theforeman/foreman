require 'rubygems'
require 'fileutils'

module GW
  class Tftp
    # creates TFTP link to a predefine syslinux config file
    # parameter is a array ["mac",'osname','arch'...]
    # e.g. ["00:11:22:33:44:55:66:77",'centos','i386'...]
    def self.create params
      mac, os, arch, serial = params
      return nil if mac.nil? or os.nil? or arch.nil?

      serial = setserial serial
      dst = "#{os}-#{arch}#{serial}"
      link=link(mac)

      FileUtils.rm_f link
      FileUtils.ln_s dst, link
    end

    # removes links created by create method
    # parmater is a mac address
    def self.remove mac
      FileUtils.rm_f link(mac.to_s)
    end

    private
    def self.link mac
        $settings[:tftppath]+"/01-"+mac.gsub(/:/,"-").downcase
    end

    def self.setserial serial
      serial =~ /^(\d),(\d+)/ ? "-#{$1}-#{$2}" : nil
    end
  end

  class Puppetca
    # removes old certificate if it exists and removes autosign entry
    # parameter is the fqdn to use
    def self.clean fqdn
      command = "/usr/bin/sudo -S /usr/sbin/puppetca --clean #{fqdn}< /dev/null"
      system "#{command} >> /tmp/puppetca.log 2>&1"

      #remove fqdn from autosign if exists
      entries =  open("/etc/puppet/autosign.conf", File::RDONLY).readlines.collect do |l| 
        l if l.chomp != fqdn
      end
      entries.uniq!
      entries.delete(nil)
      autosign = open("/etc/puppet/autosign.conf", File::TRUNC|File::RDWR)
      autosign.write entries
      autosign.close
    end

    # add fqdn to puppet autosigns file
    # parameter is fqdn to use
    def self.sign fqdn
      autosign = open("/etc/puppet/autosign.conf", File::RDWR)
      # Check that we dont have that host already
      found = false
      autosign.each_line { |line| found = true if line.chomp == fqdn }
      autosign.puts fqdn if found == false
      autosign.close
    end

  end

end

