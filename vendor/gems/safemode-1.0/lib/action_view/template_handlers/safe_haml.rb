require 'safemode'
require 'haml/safemode'

module ActionView
  module TemplateHandlers
    class SafeHaml < TemplateHandler
      include Compilable rescue nil # does not exist prior Rails 2.1
      extend SafemodeHandler
      
      def self.line_offset
      3
      end

      def compile(template)
        # Rails 2.0 passes the template source, while Rails 2.1 passes the
        # template instance
        src = template.respond_to?(:source) ? template.source : template
        filename = template.filename rescue nil

        options = Haml::Template.options.dup
        haml = Haml::Engine.new template, options
        methods = delegate_methods + ActionController::Routing::Routes.named_routes.helpers
        haml.precompile_for_safemode filename, ignore_assigns, methods
      end
    end
  end
end