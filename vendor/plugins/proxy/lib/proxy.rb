require 'rubygems'
require 'fileutils'
require 'pathname'

module GW
  # searches for binaries in predinfed directories and user PATH
  # accepts a binary name and an array of paths to search first
  # if path is ommited will search only in user PATH
  def self.which(bin, *path)
    path += ENV['PATH'].split(File::PATH_SEPARATOR)
    path.uniq.each do |dir|
      dest = File.join(dir, bin)
      return dest if FileTest.file? dest and FileTest.executable? dest
    end
    return nil
  rescue StandardError => e
    logger.warn e
    return false
  end

  module Logger
    def logger
      if defined? Rails and defined? Rails.logger
        # If we are running as a library in a rails app then use the provided logger
        Rails.logger
      else
        # We must make our own ruby based logger if we are a standalone proxy server
        require 'logger'
        # We keep the last 6 10MB log files
        l = Logger.new("/var/log/proxy", 6, 10*1024)
        l.severity = Logger::DEBUG
        l
      end
    end
  end
  class Tftp
    extend GW::Logger
    # creates TFTP link to a predefine syslinux config file
    # parameter is a array ["mac",'osname','arch'...]
    # e.g. ["00:11:22:33:44:55:66:77",'centos','i386'...]
    # FIXME: this whole pxeboot needs a design decision, does the pxelinux files managed by puppet or us?
    # a third option is to move to gpxelinux and generate the config files dynamicilly.
    def self.create params
      mac, os, arch, serial = params
      return false if mac.nil? or os.nil? or arch.nil?

      begin
        serial = setserial serial
        dst = "#{os}-#{arch}#{serial}"
        link=link(mac)

        FileUtils.mkdir_p(path) unless File.exist?(path)
        FileUtils.ln_s dst, link ,:force => true
        true
      rescue StandardError => e
        logger.info "TFTP Failed: #{e}"
        false
      end
    end

    # removes links created by create method
    # parameter is a mac address
    def self.remove mac
      FileUtils.rm_f link(mac.to_s)
    end

    private
    # returns the absolute path
    def self.path( p = SETTINGS[:tftppath] )
      # are we running in RAILS or as a standalone CGI?
      dir = RAILS_ROOT ? RAILS_ROOT : File.dirname(__FILE__)
      return (p =~ /^\//) ? p : "#{dir}/#{p}"
    end

    def self.link mac
      logger.info "**DEPRECATION WARNING*** Managing TFTP without a smart-proxy will not be supported in the next release"
      path+"/01-"+mac.gsub(/:/,"-").downcase
    end

    def self.setserial serial
      serial =~ /^(\d),(\d+)/ ? "-#{$1}-#{$2}" : nil
    end
  end

  class Puppetca
    extend GW::Logger
    # removes old certificate if it exists
    # parameter is the fqdn to use
    @sbin       = "/usr/sbin"
    @puppetdir  = "/etc/puppet"
    @ssldir     = "/var/lib/puppet/ssl"
    @deprecated = "**DEPRECATION WARNING*** Managing Puppet CA without a smart-proxy will not be supported in the next release"

    def self.clean fqdn
      logger.info @deprecated
      fqdn.downcase!
      ssldir = Pathname.new @ssldir
      unless (ssldir + "ca").directory? and File.exists? "#{@sbin}/puppetca"
        logger.error "PuppetCA: SSL/CA or puppetca unavailable on this machine"
        return false
      end
      begin
        command = "/usr/bin/sudo -S #{@sbin}/puppetca --clean #{fqdn}< /dev/null > /dev/null"
        logger.info system(command)
        return true
      rescue StandardError => e
        logger.info "PuppetCA: clean failed: #{e}"
        false
      end
    end

    #remove fqdn from autosign if exists
    def self.disable fqdn
      logger.info @deprecated
      if File.exists? "#{@puppetdir}/autosign.conf"
        entries =  open("#{@puppetdir}/autosign.conf", File::RDONLY).readlines.collect do |l|
          l if l.chomp != fqdn
        end
        entries.uniq!
        entries.delete(nil)
        autosign = open("/#{@puppetdir}/autosign.conf", File::TRUNC|File::RDWR)
        autosign.write entries
        autosign.close
      end
    end

    # add fqdn to puppet autosign file
    # parameter is fqdn to use
    def self.sign fqdn
      logger.info @deprecated
      FileUtils.touch("#{@puppetdir}/autosign.conf") unless File.exist?("#{@puppetdir}/autosign.conf")

      autosign = open("#{@puppetdir}/autosign.conf", File::RDWR)
      # Check that we don't have that host already
      found = false
      autosign.each_line { |line| found = true if line.chomp == fqdn }
      autosign.puts fqdn if found == false
      autosign.close
      true
    end
  end

  # Generic class for various puppet actions
  class Puppet
    extend GW::Logger

    def self.run *hosts
      logger.info "**DEPRECATION WARNING*** Managing Puppet without a smart-proxy will not be supported in the next release"
      puppetrun = GW::which("puppetrun", ["/usr/sbin", "/usr/bin"])
      sudo = GW::which("sudo", "/usr/bin")

      if puppetrun and sudo
        command = %x[#{sudo} #{puppetrun} --host #{hosts.join(" --host ")}]
        if command =~ /finished with exit code 0/
          return true
        else
          logger.warn command
          return false
        end
      else
        logger.warn "sudo or puppetrun binary was not found - aborting"
        return false
      end
    end
  end
end
