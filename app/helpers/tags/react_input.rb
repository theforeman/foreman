module Tags
  class ReactInput < ActionView::Helpers::Tags::Base
    def initialize(*attr)
      super
      @only_input = @options.delete(:only_input)
    end

    def only_input?
      !!@only_input
    end

    def component_name
      only_input? ? 'InputFactory' : 'FormField'
    end

    def render
      options = @options.stringify_keys
      options['value'] = options.fetch('value') { value_before_type_cast }
      add_default_name_and_id(options)
      @template_object.react_component(component_name, reactify_options(options))
    end

    private

    def reactify_options(options = {})
      react_opts = {}
      react_opts['inputSizeClass'] = options.delete('size') if options.key?('size')
      react_opts['labelSizeClass'] = options.delete('label_size') if options.key?('label_size')
      react_opts['helpBlock'] = options.delete('help_block') if options.key?('help_block') && options['help_block'].html_safe?
      react_opts['helpInline'] = options.delete('help_inline') if options.key?('help_inline') && options['help_inline'].html_safe?
      react_opts['labelHelp'] = options.delete('label_help') if options.key?('label_help')
      react_opts['wrapperClass'] = options.delete('wrapper_class') if options.key?('wrapper_class')
      react_opts.merge! deep_camelize_keys(options)
      react_opts['inputProps']['name'] = options['name'] if options['name'] && react_opts['inputProps']
      react_opts
    end

    def deep_camelize_keys(hash)
      hash.inject({}) do |res, (k, v)|
        res.tap { |r| r[k.camelize(:lower)] = v.is_a?(Hash) ? deep_camelize_keys(v.stringify_keys) : v }
      end
    end
  end
end
