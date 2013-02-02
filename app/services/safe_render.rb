# Class to parse ERB with or without Safemode rendering. Needs a set
# of variables, usually something like:
#   @allowed_vars = { :host => @host }
# so that <%= @host.name %> has the right @host variable
#
class SafeRender
  include Rails.application.routes.url_helpers
  include UnattendedHelper

  def initialize(args = {})
    @allowed_methods = args[:methods] || []
    @allowed_vars    = args[:variables] || {}
    @host            = args[:host] || @allowed_vars[:host]
  end

  def parse(object)
    return object if (!Setting[:interpolate_erb_in_parameters])

    # recurse over object types until we're dealing with a String
    case object
      when String
        parse_string object
      when Array
        object.map { |v| parse v }
      when Hash
        object.merge(object) { |k, v| parse v }
      else
        # Don't know how to parse this, send it back
        object
    end
  end

  private

  def parse_string(string)
    raise ::ForemanException.new(N_('SafeRender#parse_string was passed a %s instead of a String') % string.class) unless string.is_a? String

    if Setting[:safemode_render]
      box = Safemode::Box.new self, @allowed_methods
      box.eval(ERB.new(string, nil, '-').src, @allowed_vars)
    else
      @allowed_vars.each { |k, v| instance_variable_set "@#{k}", v }
      ERB.new(string, nil, '-').result(binding)
    end
  end

  # These helpers are provided as convenience methods available to the writers of templates

  # Calculates the media's path in relation to the domain and convert host to an IP
  def install_path
    @host.operatingsystem.interpolate_medium_vars(@host.operatingsystem.media_path(@host.medium, @host.domain), @host.architecture.name, @host.operatingsystem)
  end

  # Calculates the jumpstart path in relation to the domain and convert host to an IP
  def jumpstart_path
    @host.operatingsystem.jumpstart_path medium, @host.domain
  end

  def multiboot
    @host.operatingsystem.pxe_prefix(@host.architecture) + "-multiboot"
  end

  def miniroot
    @host.operatingsystem.initrd(@host.architecture)
  end

  def media_path
    @host.operatingsystem.medium_uri(@host)
  end

end
