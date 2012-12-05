require 'rubygems'
require 'puppet'
require 'foreman/util'

class PuppetSetting
  include Foreman::Util

  def get(*name)
    values = `#{puppetmaster} --configprint #{name.join(",")}`
    raise "unable to get #{name.inspect} Puppet setting: #{values}" unless $?.success?
    if name.size > 1
      # Parse key = value lines into hash
      values = HashWithIndifferentAccess[values.lines.map {|kv| kv.chomp.split(' = ', 2) }]
    end
    values
  end

  private

  def puppetmaster
    unless @puppetmaster
      # puppetmasterd is the old method of using puppet master which is new in puppet 2.6
      default_path = ["/usr/sbin", "/opt/puppet/bin", "/usr/bin"]

      if Puppet::PUPPETVERSION.to_i < 3
        @puppetmaster = which('puppetmasterd', default_path) || which('puppet', default_path)
      else
        @puppetmaster = which('puppet', default_path)
      end

      unless @puppetmaster and File.exists?(@puppetmaster)
        logger.warn 'unable to find puppetmaster binary'
        raise 'unable to find puppetmaster'
      end

      # Append master to the puppet command if we are not using the old puppetmasterd command
      logger.debug "Found puppetmaster at #{@puppetmaster}"
      @puppetmaster << ' master' unless @puppetmaster.include?('puppetmaster')

      # Despite the name "dir", the default settings.yaml pointed to puppet.conf so handle both files and dirs
      @puppetmaster << (FileTest.file?(SETTINGS[:puppetconfdir]) ? ' --config ' : ' --confdir ')
      @puppetmaster << SETTINGS[:puppetconfdir]

      # Per Puppet #16637, --vardir has to be explicitly set too for non-root users
      if Puppet::PUPPETVERSION.to_i >= 3
        @puppetmaster << ' --vardir ' << SETTINGS[:puppetvardir]
      end
    end
    @puppetmaster
  end

  def logger
    Rails.logger
  end
end
