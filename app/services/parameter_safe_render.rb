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
    Foreman::Renderer.render_template(subjects: { source: source, host: @host },
                                      params: { scope_class: Foreman::Renderer::Scope::Partition })
  end
end
