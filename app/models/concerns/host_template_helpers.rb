# These helpers are provided as convenience methods available to the writers of templates
# and are mixed in to Host
module HostTemplateHelpers
  extend ActiveSupport::Concern

  # Calculates the media's path in relation to the domain and convert host to an IP
  def install_path
    operatingsystem.interpolate_medium_vars(operatingsystem.media_path(medium, domain), architecture.name, operatingsystem)
  end

  # Calculates the jumpstart path in relation to the domain and convert host to an IP
  def jumpstart_path
    operatingsystem.jumpstart_path medium, domain
  end

  def multiboot
    operatingsystem.pxe_prefix(architecture) + "-multiboot"
  end

  def miniroot
    operatingsystem.initrd(architecture)
  end

  def media_path
    operatingsystem.medium_uri(self)
  end

  #returns the URL for Foreman based on the required action
  def foreman_url(action = "provision")
    # Get basic stuff
    config   = URI.parse(Setting[:unattended_url])
    protocol = config.scheme || 'http'
    port     = config.port || request.port
    host     = config.host || request.host

    url_for :only_path => false, :controller => "/unattended", :action => action,
      :protocol  => protocol, :host => host, :port => port,
      :token     => (@host.token.value unless @host.token.nil?)
  end

  attr_writer(:url_options)

  # used by url_for to generate the path correctly
  def url_options
    url_options = (@url_options || {}).deep_dup()
    url_options[:protocol] = "http://"
    url_options[:host] = Setting[:foreman_url] if Setting[:foreman_url]
    url_options
  end

end
