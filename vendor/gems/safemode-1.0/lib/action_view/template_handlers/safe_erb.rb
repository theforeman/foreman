require 'safemode'
require 'erb'

module ActionView
  module TemplateHandlers
    class SafeErb < TemplateHandler
      include Compilable rescue nil # does not exist prior Rails 2.1
      extend SafemodeHandler

      def self.line_offset
        0
      end

      def compile(template)
        # Rails 2.0 passes the template source, while Rails 2.1 passes the
        # template instance
        src = template.respond_to?(:source) ? template.source : template
        filename = template.filename rescue nil
        erb_trim_mode = '-'

        # code = ::ERB.new(src, nil, @view.erb_trim_mode).src
        code = ::ERB.new("<% __in_erb_template=true %>#{src}", nil, erb_trim_mode, '@output_buffer').src
        # Ruby 1.9 prepends an encoding to the source. However this is
        # useless because you can only set an encoding on the first line
        RUBY_VERSION >= '1.9' ? src.sub(/\A#coding:.*\n/, '') : src

        code.gsub!('\\','\\\\\\') # backslashes would disappear in compile_template/modul_eval, so we escape them

        code = <<-CODE
          handler = ActionView::TemplateHandlers::SafeHaml
          assigns = handler.valid_assigns(@template.assigns)
          methods = handler.delegate_methods(self)
          code = %Q(#{code});

          box = Safemode::Box.new(self, methods, #{filename.inspect}, 0)
          box.eval(code, assigns, local_assigns, &lambda{ |*args| yield(*args) })
        CODE
        # puts code
        code
      end
    end
  end
end
