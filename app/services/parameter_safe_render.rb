# Class to parse ERB with or without Safemode rendering. Needs a set
# of variables, usually something like:
#   @allowed_vars = { :host => @host }
# so that <%= @host.name %> has the right @host variable
#
class ParameterSafeRender
  include Foreman::Renderer
  def initialize(host)
    @host = host
  end

  def render(value)
    render_object(value)
  end

  private

  def render_object(object)
    return object if (!Setting[:interpolate_erb_in_parameters])

    # recurse over object types until we're dealing with a String
    case object
    when String
      render_string object
    when Array
      object.map { |v| render_object v }
    when Hash
      object.merge(object) { |k, v| render_object v }
    else
      # Don't know how to parse this, send it back
      object
    end
  end

  def render_string(string)
    render_safe(string, ::Foreman::Renderer::ALLOWED_HOST_HELPERS, :host => @host)
  end
end
