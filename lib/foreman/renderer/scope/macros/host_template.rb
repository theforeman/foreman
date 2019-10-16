module Foreman
  module Renderer
    module Scope
      module Macros
        module HostTemplate
          include Foreman::Renderer::Errors

          def host_enc(*path)
            check_host
            return enc if path.compact.empty?
            path.reduce(enc) do |e, step|
              e.fetch(step)
            rescue KeyError
              raise HostENCParamUndefined.new(name: path, step: step, host: host)
            end
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

          def host_param_true?(name, default_value = false)
            check_host
            if host.params.has_key?(name)
              Foreman::Cast.to_bool(host.params[name])
            else
              default_value
            end
          end

          def host_param_false?(name, default_value = false)
            check_host
            if host.params.has_key?(name)
              Foreman::Cast.to_bool(host.params[name]) == false
            else
              default_value
            end
          end

          def root_pass
            check_host
            host.root_pass
          end

          def grub_pass
            return '' unless @grub
            host.grub_pass.start_with?('$1$') ? "--md5pass=#{host.grub_pass}" : "--iscrypted --password=#{host.grub_pass}"
          end

          def ks_console
            (@port && @baud) ? "console=ttyS#{@port},#{@baud}" : ''
          end

          private

          def enc
            @enc ||= host.info.deep_dup
          end

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
