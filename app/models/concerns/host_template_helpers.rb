# These helpers are provided as convenience methods available to the writers of templates
# and are mixed in to Host
module HostTemplateHelpers
  extend ActiveSupport::Concern
  include ::Foreman::ForemanUrlRenderer

  delegate :medium_uri, to: :medium_provider

  # Calculates the media's path in relation to the domain and convert host to an IP
  def install_path
    medium_provider.interpolate_vars(medium.media_dir).to_s
  end

  # Calculates the jumpstart path in relation to the domain and convert host to an IP
  def jumpstart_path
    operatingsystem.jumpstart_path medium, domain
  end

  def multiboot
    operatingsystem.pxe_prefix(medium_provider) + "-multiboot"
  end

  def miniroot
    operatingsystem.initrd(medium_provider)
  end

  attr_writer(:url_options)

  # used by url_for to generate the path correctly
  def url_options
    url_options = (@url_options || {}).deep_dup()
    url_options[:protocol] = "http://"
    url_options[:host] = Setting[:foreman_url] if Setting[:foreman_url]
    url_options
  end

  def medium_provider
    @medium_provider ||= Foreman::Plugin.medium_providers_registry.find_provider(self)
  end
end
