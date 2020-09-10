module Foreman
  module Renderer
    module Errors
      class RenderingError < Foreman::Exception
        def initialize(**params)
          super(self.class::MESSAGE, params)
        end
      end

      class SyntaxError < RenderingError
        MESSAGE = N_('Syntax error occurred while parsing the template %{name}, make sure you have all ERB tags properly closed and the Ruby syntax is valid. The Ruby error: %{message}').freeze
      end

      class WrongSubnetError < RenderingError
        MESSAGE = N_('%{object_name} is a %{object_class}, expected a subnet').freeze
      end

      class HostUnknown < RenderingError
        MESSAGE = N_('This templates requires a host to render but none was specified').freeze
      end

      class HostParamUndefined < RenderingError
        MESSAGE = N_('Parameter %{name} is not set for host %{host}').freeze
      end

      class HostENCParamUndefined < RenderingError
        MESSAGE = N_('Parameter %{name} is not set in host %{host} ENC output, resolving failed on step %{step}').freeze
      end

      class FilteredGlobalSettingAccessed < RenderingError
        MESSAGE = N_('Global setting %{name} is not accessible in safe-mode').freeze
      end

      class UnknownHostStatusError < RenderingError
        MESSAGE = N_('Unknown host status "%{status}" was specified in host_status macro, use one of %{statuses}').freeze
      end

      class UndefinedInput < RenderingError
        MESSAGE = N_('Rendering failed, no input with name "%{s}" for input macro found').freeze
      end

      class UnknownReportColumn < RenderingError
        MESSAGE = N_('Rendering failed, one or more unknown columns specified for ordering - "%{unknown}"').freeze
      end
    end
  end
end
