module Foreman
  module Renderer
    module Errors
      class RenderingError < Foreman::Exception
        def initialize(**params)
          super(N_(self.class::MESSAGE), params)
        end
      end

      class SyntaxError < RenderingError
        MESSAGE = 'Syntax error occurred while parsing the template %{name}, make sure you have all ERB tags properly closed and the Ruby syntax is valid. The Ruby error: %{message}'.freeze
      end

      class WrongSubnetError < RenderingError
        MESSAGE = '%{object_name} is a %{object_class}, expected a subnet'.freeze
      end

      class HostUnknown < RenderingError
        MESSAGE = 'This templates requires a host to render but none was specified'.freeze
      end

      class HostParamUndefined < RenderingError
        MESSAGE = 'Parameter %{name} is not set for host %{host}'.freeze
      end

      class HostENCParamUndefined < RenderingError
        MESSAGE = 'Parameter %{name} is not set in host %{host} ENC output, resolving failed on step %{step}'.freeze
      end

      class FilteredGlobalSettingAccessed < RenderingError
        MESSAGE = 'Global setting "%s" is not accessible in safe-mode'.freeze
      end
    end
  end
end
