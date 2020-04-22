# Recursively parses a hash and in case the value is a string,
# renders it using ERB. It respects the safe-mode settings.
#
class ParameterSafeRender
  def initialize(host)
    @host = host
  end

  def render(value)
    return value unless interpolate_erb?

    render_object(value)
  end

  private

  attr_reader :host

  def interpolate_erb?
    @interpolate_erb = Setting[:interpolate_erb_in_parameters] if @interpolate_erb.nil?
    @interpolate_erb
  end

  def render_object(object)
    case object
    when String
      render_string object
    when Array
      object.map { |v| render_object v }
    when Hash
      object.merge(object) { |k, v| render_object v }
    else
      object
    end
  end

  def render_string(string)
    # exit early if there is nothing to parse
    return string unless string.contains_erb?

    source = Foreman::Renderer::Source::String.new(content: string)
    scope = Foreman::Renderer.get_scope(klass: Foreman::Renderer::Scope::Partition, host: host)
    Foreman::Renderer.render(source, scope)
  end
end
