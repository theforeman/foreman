module Foreman
  module Controller
    module TemplateRendering
      extend ActiveSupport::Concern

      private

      def render_template(template:, type:)
        return safe_render(template) if template

        error_message = N_("unable to find %{type} template for %{host} running %{os}")
        render_error(error_message, type: type, host: @host.name, os: @host.operatingsystem, status: :not_found)
      end

      def safe_render(template)
        render plain: template.render(host: @host, params: params).html_safe
      rescue StandardError => error
        Foreman::Logging.exception("Error rendering the #{template.name} template", error)
        render_error('There was an error rendering the %{name} template: %{error}',
          :name => template.name,
          :error => error.message,
          :status => :internal_server_error
        )
      end

      def render_error(message, options)
        status = options.delete(:status) || :not_found
        logger.error(message % options)
        render(plain: "#{message % options}\n", :status => status)
      end
    end
  end
end
