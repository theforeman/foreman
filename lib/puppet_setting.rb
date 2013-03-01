require 'rubygems'
require 'puppet'
require 'foreman/util'

class PuppetSetting
  include Foreman::Util

  def get(*name)
    cmd = "#{puppetmaster} --configprint #{name.join(",")} 2>&1"

    values = if !SETTINGS[:puppetgem] && defined? Bundler && Bundler.responds_to(:with_clean_env)
      # execute in a clean env to prevent bundler interfering with loading Ruby for Puppet
      Bundler.with_clean_env do
        `#{cmd}`
      end
    else
      # if puppetgem is set, the user intends to rely on bundler
      `#{cmd}`
    end
    raise "unable to get #{name.inspect} Puppet setting, `#{cmd}` returned #{$?}: #{values}" unless $?.success?

    if name.size > 1
      # Parse key = value lines into hash
      values = HashWithIndifferentAccess[values.lines.map {|kv| kv.chomp.split(' = ', 2) }]
    end
    values
  end

  private

  def puppetmaster
    unless @puppetmaster
      # puppetgem allows the user to prefer their default PATH
      default_path = SETTINGS[:puppetgem] ? [] : ["/usr/sbin", "/opt/puppet/bin", "/usr/bin"]

      # puppetmasterd is the old method of using puppet master which is new in puppet 2.6
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
      @puppetmaster << ' master' unless @puppetmaster.include?('puppetmaster')

      # Despite the name "dir", the default settings.yaml pointed to puppet.conf so handle both files and dirs
      @puppetmaster << (FileTest.file?(SETTINGS[:puppetconfdir]) ? ' --config ' : ' --confdir ')
      @puppetmaster << SETTINGS[:puppetconfdir]

      # Per Puppet #16637, --vardir has to be explicitly set too for non-root users
      if Puppet::PUPPETVERSION.to_i >= 3
        @puppetmaster << ' --vardir ' << SETTINGS[:puppetvardir]
      end

      logger.debug "Using puppetmaster command: #{@puppetmaster}"
    end
    @puppetmaster
  end

  def logger
    Rails.logger
  end
end
