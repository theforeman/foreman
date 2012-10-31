# These helpers are provided as convenience methods available to the writers of templates
# and are mixed in to Host
module HostTemplateHelpers
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
    url_for :only_path => false, :controller => "unattended",
            :action => action,
            :host => (Setting[:foreman_url].blank? ? request_url : Setting[:foreman_url]),
            :token => (@host.token.value unless @host.token.nil?)
  end
end
