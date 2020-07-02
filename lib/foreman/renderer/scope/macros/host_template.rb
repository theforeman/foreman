module Foreman
  module Renderer
    module Scope
      module Macros
        module HostTemplate
          include Foreman::Renderer::Errors
          extend ApipieDSL::Module

          apipie :class do
            name 'Host related macros'
            sections only: %w[all provisioning partition_tables]
          end

          apipie :method, "Allows to retrieve parameters from host's ENC" do
            list :path, 'List of strings representing path to a parameter to be returned'
            raises error: HostENCParamUndefined, desc: "when the parameter is not set in host's ENC output"
            returns one_of: [Hash, Object], desc: 'The value of a parameter or a key=value object with all information from ENC'
            example "host_enc('parameters', 'enable-puppet5') #=> true"
            example 'host_enc #=> {"parameters"=>{...}'
          end
          def host_enc(*path)
            check_host
            return enc if path.compact.empty?
            path.reduce(enc) do |e, step|
              e.fetch(step)
            rescue KeyError
              raise HostENCParamUndefined.new(name: path, step: step, host: host)
            end
          end

          apipie :method, 'Allows to retrieve a parameter set on host' do
            required :param_name, String, desc: 'name of the parameter'
            optional :default, Object, desc: 'value to be returned if the parameter is not set on host'
            returns Object, desc: 'Host parameter or default value'
            example "host_param('systemLocale') #=> 'en-US'"
            example "host_param('partitioning-method', 'regular') #=> 'regular'"
          end
          def host_param(param_name, default = nil)
            check_host
            host.host_param(param_name) || default
          end

          apipie :method, 'Allows to retrieve a parameter set on host' do
            required :param_name, String, desc: 'name of the parameter'
            raises error: HostParamUndefined, desc: 'when the parameter with provided name does not exist'
            returns Object, desc: 'Host parameter'
            example "host_param('systemLocale') #=> 'en-US'"
            example "host_param('partitioning-method') #=> HostParamUndefined error is raised"
          end
          def host_param!(param_name)
            check_host_param(param_name)
            host_param(param_name)
          end

          apipie :method, 'Returns puppet classes assigned to the host' do
            returns Array, desc: 'Puppet classes assigned to the host'
          end
          def host_puppet_classes
            check_host
            host.puppetclasses
          end

          apipie :method, 'Checks whether a parameter value is truthly or not' do
            required :name, String, desc: 'name of the parameter'
            optional :default_value, Object, desc: 'value to be returned if the parameter is not set on host', default: false
            returns one_of: [true, false], desc: 'Returns true if the value of a parameter can be considered as truthly, false otherwise'
            example "host_param_true?('use-ntp') #=> true"
            example "host_param_true?('use-ntp', false) #=> false if a host has no 'use-ntp' parameter"
            see 'host_param_false?', description: '#host_param_false?', scope: Foreman::Renderer::Scope::Macros::HostTemplate
          end
          def host_param_true?(name, default_value = false)
            check_host
            if host.params.has_key?(name)
              Foreman::Cast.to_bool(host.params[name])
            else
              default_value
            end
          end

          apipie :method, 'Checks whether a parameter value is falsy or not' do
            required :name, String, desc: 'name of the parameter'
            optional :default_value, Object, desc: 'value to be returned if the parameter is not set on host', default: false
            returns one_of: [true, false], desc: 'Returns false if the value of a parameter can be considered as falsy, true otherwise'
            example "host_param_false?('use-ntp') #=> true"
            example "host_param_false?('use-ntp', true) #=> true if a host has no 'use-ntp' parameter"
            see 'host_param_true?', description: '#host_param_true?', scope: Foreman::Renderer::Scope::Macros::HostTemplate
          end
          def host_param_false?(name, default_value = false)
            check_host
            if host.params.has_key?(name)
              Foreman::Cast.to_bool(host.params[name]) == false
            else
              default_value
            end
          end

          apipie :method, 'Returns root user\'s encrypted password for the host' do
            returns String, desc: 'Returns root user\'s encrypted password for the host'
            example 'root_pass #=> 9yxjIDK8FYVlQzHGhasqW/'
          end
          def root_pass
            check_host
            host.root_pass
          end

          apipie :method, 'Returns options for GRUB bootloader containing password' do
            returns String, desc: 'Returns options for GRUB bootloader containing password'
            example 'grub_pass #=> "--md5pass=$1$org$9yxjIDK8FYVlQzHGhasqW/"'
            example 'grub_pass #=> "--iscrypted --password=9yxjIDK8FYVlQzHGhasqW/"'
          end
          def grub_pass
            return '' unless @grub
            host.grub_pass.start_with?('$1$') ? "--md5pass=#{host.grub_pass}" : "--iscrypted --password=#{host.grub_pass}"
          end

          apipie :method, 'Returns console Kickstart option for bootloader' do
            returns String, desc: 'Returns console Kickstart option for bootloader'
            example 'ks_console #=> "console=ttyS99"'
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
