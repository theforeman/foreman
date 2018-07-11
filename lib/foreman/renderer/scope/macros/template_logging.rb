module Foreman
  module Renderer
    module Scope
      module Macros
        module TemplateLogging
          def template_logger
            @template_logger ||= Foreman::Logging.logger('templates')
          end

          class_eval do
            [:debug, :info, :warn, :error, :fatal].each do |level|
              define_method("log_#{level}".to_sym) do |msg|
                template_logger.send(level, msg) if msg.present?
              end
            end
          end
        end
      end
    end
  end
end
