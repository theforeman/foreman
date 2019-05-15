module Tags
  class ReactInput < ActionView::Helpers::Tags::Base
    def render
      options = @options.stringify_keys
      options['value'] = options.fetch('value') { value_before_type_cast }
      add_default_name_and_id(options)
      wrapper_id = options.fetch('id') + '_wrapper'
      content_tag('div', '', 'id' => wrapper_id) +
        @template_object.mount_react_component('FormField', "##{wrapper_id}", reactify_options(options).to_json, flatten_data: true)
    end

    private

    def reactify_options(options = {})
      react_opts = {}
      react_opts['inputSizeClass'] = options.delete('size') if options.key?('size')
      react_opts['labelSizeClass'] = options.delete('label_size') if options.key?('label_size')
      react_opts.merge! deep_camelize_keys(options)
      react_opts
    end

    def deep_camelize_keys(hash)
      hash.inject({}) do |res, (k, v)|
        res.tap { |r| r[k.camelize(:lower)] = v.is_a?(Hash) ? deep_camelize_keys(v.stringify_keys) : v }
      end
    end
  end
end
