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
      options.each { |k, v| react_opts[k.camelize(:lower)] = v }
      react_opts['inputProps']['name'] = options['name'] if options['name'] && react_opts['inputProps']
      react_opts
    end
  end
end
