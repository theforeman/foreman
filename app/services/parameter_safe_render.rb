# Recursively parses a hash and in case the value is a string,
# renders it using ERB. It respects the safe-mode settings.
#
class ParameterSafeRender
  def initialize(host)
    @host = host
  end

  def render(value)
    render_object(value)
  end

  private

  attr_reader :host

  def render_object(object)
    return object unless (Setting[:interpolate_erb_in_parameters])

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
    source = Foreman::Renderer::Source::String.new(content: string)
    scope = Foreman::Renderer.get_scope(klass: Foreman::Renderer::Scope::Partition, host: host)
    Foreman::Renderer.render(source, scope)
  end
end
