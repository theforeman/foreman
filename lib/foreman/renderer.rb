module Foreman
  module Renderer
    def render_safe template, allowed_methods = [], allowed_vars = {}

      if SETTINGS[:safemode_render]
        box = Safemode::Box.new self, allowed_methods
        box.eval(ERB.new(template, nil, '-').src, allowed_vars)
      else
        ERB.new(template, nil, '-').result(binding)
      end
    end
  end
end
