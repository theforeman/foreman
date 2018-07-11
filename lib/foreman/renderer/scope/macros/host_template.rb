module Foreman
  module Renderer
    module Scope
      module Macros
        module HostTemplate
          include Foreman::Renderer::Errors

          def host_enc(*path)
            check_host
            @enc ||= host.info.deep_dup
            return @enc if path.compact.empty?
            enc = @enc
            step = nil
            path.each { |step| enc = enc.fetch step }
            enc
          rescue KeyError
            raise HostENCParamUndefined.new(name: path, step: step, host: host)
          end

          def host_param(param_name, default = nil)
            check_host
            host.host_param(param_name) || default
          end

          def host_param!(param_name)
            check_host_param(param_name)
            host_param(param_name)
          end

          def host_puppet_classes
            check_host
            host.puppetclasses
          end

          def host_param_true?(name)
            check_host
            host.params.has_key?(name) && Foreman::Cast.to_bool(host.params[name])
          end

          def host_param_false?(name)
            check_host
            host.params.has_key?(name) && Foreman::Cast.to_bool(host.params[name]) == false
          end

          private

          def check_host
            raise HostUnknown if host.nil?
          end

          def check_host_param(name)
            check_host
            raise HostParamUndefined.new(name: name, host: host) unless host.params.key?(name)
          end
        end
      end
    end
  end
end
