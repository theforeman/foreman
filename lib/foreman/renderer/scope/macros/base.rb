module Foreman
  module Renderer
    module Scope
      module Macros
        module Base
          include Foreman::Renderer::Errors
          include ::Foreman::ForemanUrlRenderer

          attr_reader :template_name, :medium_provider

          delegate :medium_uri, to: :medium_provider

          def subnet_has_param?(subnet, param_name)
            validate_subnet(subnet)
            subnet.parameters.exists?(name: param_name)
          end

          def global_setting(name, blank_default = nil)
            raise FilteredGlobalSettingAccessed.new(name: name) if Setting[:safemode_render] && !Foreman::Renderer.config.allowed_global_settings.include?(name.to_sym)
            setting = Setting.find_by_name(name.to_sym)
            (setting.settings_type != "boolean" && setting.value.blank?) ? blank_default : setting.value
          end

          def plugin_present?(name)
            Foreman::Plugin.find(name).present?
          end

          def subnet_param(subnet, param_name)
            validate_subnet(subnet)
            param = subnet.parameters.where(name: param_name).first
            param.nil? ? nil : param.value
          end

          def foreman_server_fqdn
            config = URI.parse(Setting[:foreman_url])
            config.host
          end

          def foreman_server_url
            Setting[:foreman_url]
          end

          def pxe_kernel_options
            return '' unless host || host.operatingsystem
            host.operatingsystem.pxe_kernel_options(host.params).join(' ')
          rescue => e
            template_logger.warn "Unable to build PXE kernel options: #{e}"
            ''
          end

          def save_to_file(filename, content)
            "cat << EOF > #{filename}\n#{content}EOF"
          end

          def indent(count, skip1: false)
            return unless block_given? && (text = yield.to_s)
            prefix = ' ' * count
            result = []
            text.each_line.with_index do |line, line_no|
              if line_no == 0 && skip1
                result << line
              else
                result << prefix + line
              end
            end
            result.join('')
          end

          def dns_lookup(name_or_ip)
            resolver = Resolv::DNS.new
            resolver.timeouts = Setting[:dns_timeout]
            begin
              resolver.getname(name_or_ip)
            rescue Resolv::ResolvError
              resolver.getaddress(name_or_ip)
            end
          rescue StandardError => e
            log_warn "Template helper dns_lookup failed: #{e} (timeout set to #{Setting[:dns_timeout]})"
            raise e
          end

          def default_template_url(template, hostgroup)
            uri      = URI.parse(Setting[:unattended_url])
            host     = uri.host
            port     = uri.port
            protocol = uri.scheme

            url_for(:only_path => false, :action => :hostgroup_template, :controller => '/unattended',
                    :id => template.name, :hostgroup => hostgroup.title, :protocol => protocol,
                    :host => host, :port => port)
          end

          def load_hosts(search: '', includes: nil, preload: nil)
            load_resource(klass: Host, search: search, permission: 'view_hosts', includes: includes, preload: preload)
          end

          def all_host_statuses
            @all_host_statuses ||= HostStatus.status_registry.to_a.sort_by(&:status_name)
          end

          def all_host_statuses_hash(host)
            all_host_statuses.map { |status| [status.status_name, host_status(host, status.status_name).status] }.to_h
          end

          def host_status(host, name)
            klass = all_host_statuses.find { |status| status.status_name == name }
            raise UnknownHostStatusError.new(status: name, statuses: all_host_statuses.map(&:status_name).join(',')) if klass.nil?
            host.get_status(klass)
          end

          def preview?
            mode == Renderer::PREVIEW_MODE
          end

          def rand_hex(n)
            SecureRandom.hex(n)
          end

          def rand_name
            NameGenerator.new.generate_next_random_name
          end

          def mac_name(mac_address)
            NameGenerator.new.generate_next_mac_name(mac_address)
          end

          def host_kernel_release(host)
            host&.kernel_release&.value
          end

          def host_uptime_seconds(host)
            host&.uptime_seconds
          end

          def host_memory(host)
            host&.ram
          end

          def host_sockets(host)
            host&.sockets
          end

          def host_cores(cores)
            host&.cores
          end

          def host_virtual(host)
            host&.virtual
          end

          private

          def validate_subnet(subnet)
            raise WrongSubnetError.new(object_name: subnet.to_s, object_class: subnet.class.to_s) unless subnet.is_a?(Subnet)
          end

          # returns a batched relation, use either
          #   .each { |batch| batch.each { |record| record.name }}
          # or
          #   .each_record { |record| record.name }
          def load_resource(klass:, search:, permission:, batch: 1_000, includes: nil, limit: nil, select: nil, joins: nil, where: nil, preload: nil)
            limit ||= 10 if preview?

            base = klass
            base = base.search_for(search)
            base = base.preload(preload) unless preload.nil?
            base = base.includes(includes) unless includes.nil?
            base = base.joins(joins) unless joins.nil?
            base = base.authorized(permission) unless permission.nil?
            base = base.limit(limit) unless limit.nil?
            base = base.where(where) unless where.nil?
            base = base.select(select) unless select.nil?
            base.in_batches(of: batch)
          end
        end
      end
    end
  end
end
