module Foreman
  module Renderer
    module Scope
      module Macros
        module Base
          extend ApipieDSL::Module
          include Foreman::Renderer::Errors
          include ::Foreman::ForemanUrlRenderer
          include ActiveSupport::NumberHelper

          attr_reader :template_name, :medium_provider

          delegate :medium_uri, to: :medium_provider

          apipie :class, 'Base macros to use within a template' do
            name 'Base'
            sections only: %w[all reports provisioning jobs partition_tables]
          end

          apipie :method, 'Returns true if subnet has a given parameter set, false otherwise' do
            desc 'This does not take inheritance into consideration, it only
              searches for parameters assigned directly to the subnet.'
            required :subnet, 'Subnet', desc: 'a __Subnet__ object for which we check the parameter presence'
            required :param_name, String, desc: 'a parameter __name__ to check the presence of'
            returns one_of: [true, false]
            raises error: WrongSubnetError, desc: 'when user passes non-subnet object as __subnet__ parameter'
          end
          def subnet_has_param?(subnet, param_name)
            validate_subnet(subnet)
            subnet.parameters.exists?(name: param_name)
          end

          apipie :method, 'Returns the value of global setting' do
            settings = Foreman::Renderer.config.allowed_global_settings.sort.map { |s| "__#{s}__" }.join(', ')
            desc "Not not all settings are exposed, only those which are allowed via safe mode: #{settings}"
            required :name, String, desc: 'the name of the setting which can be found by hovering the setting with mouse cursor in the UI, or via API/CLI'
            optional :blank_default, Object, desc: 'if the setting is not set to any value, this value will be returned instead', default: nil
            raises error: FilteredGlobalSettingAccessed, desc: 'when user setting is not accessible in safe mode'
            returns Object, desc: 'The value of global setting, e.g. String, Integer, Array, Provisioning Template etc'
            example "global_setting('outofsync_interval', 30) # => 30"
          end
          def global_setting(name, blank_default = nil)
            raise FilteredGlobalSettingAccessed.new(name: name) if Setting[:safemode_render] && !Foreman::Renderer.config.allowed_global_settings.include?(name.to_sym)
            setting = Foreman.settings.find(name)
            (setting.settings_type != "boolean" && setting.value.blank?) ? blank_default : setting.value
          end

          apipie :method, 'Returns true if plugin with a given name is installed in this Foreman instance' do
            required :name, String, desc: 'The name of the plugin'
            returns one_of: [true, false]
            example "plugin_present?('foreman_ansible') # => true"
            example "plugin_present?('foreman_virt_who_configure') # => false"
          end
          def plugin_present?(name)
            Foreman::Plugin.find(name).present?
          end

          apipie :method, 'Returns the value of parameter set on subnet' do
            required :name, 'Subnet', desc: 'the subnet to load the parameter from'
            required :param_name, String, desc: 'the name of the subnet parameter'
            returns one_of: [nil, Object], desc: 'The value of the parameter, type of the value is determined by the parameter type. If the parameter with a given name is undefined for a subnet, nil is returned'
            example "subnet_param(@subnet, 'gateway') # => '192.168.0.1"
          end
          def subnet_param(subnet, param_name)
            validate_subnet(subnet)
            param = subnet.parameters.where(name: param_name).first
            param.nil? ? nil : param.value
          end

          apipie :method, 'Returns the server FQDN based on global setting foreman_url' do
            returns String, desc: 'FQDN based on foreman_url global setting'
            example "foreman_server_fqdn # => 'foreman.example.com'"
          end
          def foreman_server_fqdn
            config = URI.parse(Setting[:foreman_url])
            config.host
          end

          apipie :method, 'Returns the server URL based on global setting foreman_url' do
            returns String, desc: 'The value of the foreman_url global setting.'
            example "foreman_server_url # => 'https://foreman.example.com'"
          end
          def foreman_server_url
            Setting[:foreman_url]
          end

          apipie :method, 'Returns the list of kernel options during PXE boot' do
            desc "It requires a @host variable to contain a Host object. Otherwise returns empty string.
              The list is determined by @host parameter called `kernelcmd`. If the host OS
              is RHEL, it will also add `modprobe.blacklist=$blacklisted`, where blacklisted
              modules are loaded from `blacklist` parameter.
              This is mostly useful PXELinux/PXEGrub/PXEGrub2 templates."
            returns String, desc: 'Either an empty string or a string containing a list of kernel parameters'
            example "pxe_kernel_options # => 'net.ifnames=0 biosdevname=0'"
          end
          def pxe_kernel_options
            return '' unless host || host.operatingsystem
            host.operatingsystem.pxe_kernel_options(host.params).join(' ')
          rescue => e
            template_logger.warn "Unable to build PXE kernel options: #{e}"
            ''
          end

          apipie :method, 'Generates a shell command to store the given text into a file' do
            desc "This is useful if some multiline string needs to be saved somewhere on the hard disk. This
              is typically used in provisioning or job templates, e.g. when puppet configuration file is
              generated based on host configuration and stored for puppet agent. The content must end with
              a line end, if not an extra trailing line end is appended automatically."
            required :filename, String, desc: 'the file path to store the content to'
            required :content, String, desc: 'content to be stored'
            keyword :verbatim, [true, false], desc: 'Controls whether the file should be put on disk as-is or if variables should be replaced by shell before the file is written out', default: false
            returns String, desc: 'String representing the shell command'
            example "save_to_file('/etc/motd', \"hello\\nworld\\n\") # => 'cat << EOF-0e4f089a > /etc/motd\\nhello\\nworld\\nEOF-0e4f089a'"
          end
          def save_to_file(filename, content, verbatim: false)
            filename = filename.shellescape
            delimiter = 'EOF-' + Digest::SHA512.hexdigest(filename)[0..7]
            if content.empty?
              "cp /dev/null #{filename}"
            elsif verbatim
              content = Base64.encode64(content)
              "cat << #{delimiter} | base64 -d > #{filename}\n#{content}#{delimiter}"
            else
              content += "\n" unless content.end_with?("\n")
              "cat << #{delimiter} > #{filename}\n#{content}#{delimiter}"
            end
          end

          apipie :method, desc: 'Takes a block of code, runs it and prefixes the resulting text by given number of spaces' do
            desc "This is useful when rendering output is a whitespace sensitive format, such as YAML."
            required :count, Integer, desc: 'The number of spaces'
            keyword :skip1, [true, false], desc: 'Skips the first line prefixing, defaults to false', default: false
            block 'Optional. Does nothing if no block is given', schema: '{ code }'
            returns String, desc: 'The indented text, that was the result of block of code'
            example "indent(2) { snippet('epel') } # => '  echo Installing yum repo\n  yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm'"
            example "indent(2) { snippet('epel', skip1: true) } # => 'echo Installing yum repo\n  yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm'"
            example "indent 4 do\n    snippet 'subscription_manager_registration'\nend"
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

          apipie :method, 'Performs a DNS lookup on Foreman server' do
            required :name_or_ip, String, desc: 'a hostname or IP address to perform DNS lookup for'
            returns String, desc: 'IP resolved via DNS if hostname was given, hostname if an IP was given.'
            raises error: Timeout::Error, desc: 'when DNS resolve could not be performed in time set by global setting `dns_timeout`'
            raises error: Resolv::ResolvError, desc: 'when DNS resolve failed, e.g. because of misconfigured DNS server or invalid query'
            example "dns_lookup('example.com') # => '10.0.0.1'"
            example "dns_lookup('10.0.0.1') # => 'example.com'"
            example "echo <%= dns_lookup('example.com') %> example.com >> /etc/hosts"
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

          apipie :method, 'Returns a URL where a given template can be fetched from for a given host group' do
            desc "This is mostly useful for host group based provisioning in PXELinux/PXEGrub/PXEGrub2 templates,
              where boot menu items are generated based on kickstart files renderer for host groups. The URL
              is based on `unattended_url` global setting."
            required :template, String, desc: 'the template object (needs to respond to name)'
            required :hostgroup, String, desc: 'the hostgroup object (needs to respond to title)'
            returns String, desc: 'The URL for downloading the rendered template'
            example "default_template_url(template_object, hostgroup_object) # => 'http://foreman.example.com/unattended/template/WebServerKickstart/Finance'"
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

          apipie :method, 'Returns an array of all possible host status classes sorted alphabetically by status name' do
            desc "Useful to generate a report on all host statuses."
            returns array_of: 'HostStatus', desc: 'Array of host status objects'
            example "all_host_statuses # => [Katello::PurposeAddonsStatus, HostStatus::BuildStatus, ForemanOpenscap::ComplianceStatus, HostStatus::ConfigurationStatus, Katello::ErrataStatus, HostStatus::ExecutionStatus, Katello::PurposeRoleStatus, Katello::PurposeSlaStatus, Katello::SubscriptionStatus, Katello::PurposeStatus, Katello::TraceStatus, Katello::PurposeUsageStatus] "
          end
          def all_host_statuses
            @all_host_statuses ||= HostStatus.status_registry.to_a.sort_by(&:status_name)
          end

          apipie :method, 'Returns hash representing all statuses for a given host' do
            required :host, 'Host::Managed', desc: 'a host object to get the statuses for'
            returns object_of: Hash, desc: 'Hash representing all statuses for a given host'
            example 'all_host_statuses(@host) # => {"Addons"=>0, "Build"=>1, "Compliance"=>0, "Configuration"=>0, "Errata"=>0, "Execution"=>1, "Role"=>0, "Service Level"=>0, "Subscription"=>0, "System Purpose"=>0, "Traces"=>0, "Usage"=>0}'
            example "<%- load_hosts.each_record do |host| -%>\n<%= host.name -%>, <%=   all_host_statuses(host)['Subscription'] %>\n<%- end -%>"
          end
          def all_host_statuses_hash(host)
            all_host_statuses.map { |status| [status.status_name, host_status(host, status.status_name).status] }.to_h
          end

          apipie :method, 'Returns a specific status for a given host' do
            desc "The return value is a human readable representation of the status.
              For details about the number meaning, see documentation for every status class."
            required :host, 'Host::Managed', desc: 'a host object for which the status will be checked'
            required :name, HostStatus.status_registry.to_a.map(&:status_name).sort, desc: 'name of the host substatus to be checked'
            returns String, desc: 'A human readable, textual representation of the status for a given host'
            example 'host_status(@host, "Subscription") # => "Fully entitled"'
          end
          def host_status(host, name)
            klass = all_host_statuses.find { |status| status.status_name == name }
            raise UnknownHostStatusError.new(status: name, statuses: all_host_statuses.map(&:status_name).join(',')) if klass.nil?
            host.get_status(klass)
          end

          apipie :method, desc: "Returns a name of a given users auth source" do
            required :user, 'User', desc: 'a user for which the auth source name will be returned'
            returns String, desc: 'An auth source name of specified user, nil if auth source could not be found'
            example '<% load_users(search: "admin = true").each_record { |u| report_row login: u.login, auth_source: user_auth_source_name(u)  } -%>\n<%= report_render %>'
          end
          def user_auth_source_name(user)
            user.auth_source&.name
          end

          apipie :method, 'Returns true if template rendering is running in preview mode' do
            desc "This is useful if the template would execute commands, that shouldn't be
              executed while previewing the template output. Examples may be performance
              heavy operations, destructive operations etc."
            returns one_of: [true, false], desc: 'A boolean value, true for preview mode, false otherwise'
            example '<%= preview? ? "# skipping in preview mode" : @host.facts_hash["ssh::rsa::fingerprints::sha256"] -%>'
          end
          def preview?
            mode == Renderer::PREVIEW_MODE
          end

          apipie :method, 'Generates a random hex string' do
            required :n, Integer, desc: 'the argument n specifies the length of the random length. The length of the result string is twice of n.'
            returns String, desc: 'String composed of n random numbers in range of 0-255 in hexadecimal format'
            example 'rand_hex(5) # => "3bf14f69c1"'
          end
          def rand_hex(n)
            SecureRandom.hex(n)
          end

          apipie :method, 'Generates a random name' do
            returns String, desc: 'A random name that can be used as a hostname. The same function is used to suggest
              a name when provisioning a new host. The format is two names separated by dash.'
            example 'rand_name # => "addie-debem"'
          end
          def rand_name
            NameGenerator.new.generate_next_random_name
          end

          apipie :method, 'Generates a text representation of a mac address' do
            required :mac_address, String, desc: 'mac address in a format of hexadecimal numbers separated by colon'
            returns String, desc: 'A name that can be used as a hostname. It is based on passed mac-address, same
              mac-address results in the same hostname.'
            example 'mac_name("00:11:22:33:44:55") # => "hazel-diana-maruyama-feltus"'
          end
          def mac_name(mac_address)
            NameGenerator.new.generate_next_mac_name(mac_address)
          end

          apipie :method, 'Returns a kernel release installed on a host based on facts' do
            desc "Given this is based on facts, if it's rendered for multiple hosts in a single template rendering,
              it's advised to preload `kernel_release` association, see an example below."
            required :host, 'Host::Managed', desc: 'host object for which kernel released is returned'
            returns String, desc: 'String describing the kernel release'
            example 'host_kernel_release(host) # => "3.10.0-957.10.1.el7.x86_6"'
            example "<%- load_hosts(preload: :kernel_release).each_record do |host| -%>\n<%=   host.name -%>, <%=  host_kernel_release(host) %>\n<%- end -%>"
          end
          def host_kernel_release(host)
            host&.kernel_release&.value
          end

          apipie :method, 'Returns a host uptime in seconds based on facts' do
            desc "Given this is based on  e.g. reports from puppet agent, ansible runs or subscription managers
              the value is only updated on incoming report and can be inaccurate and out of date. An example
              scenario for such situation is when host reboots but puppet agent hasn't sent new facts yet."
            required :host, 'Host::Managed', desc: 'host object for which the uptime is returned'
            returns one_of: [Integer, nil], desc: 'Number representing uptime in seconds or nil in case, there is no information about host boot time'
            example 'host_uptime_seconds(host) # => 2670619'
            example 'host_uptime_seconds(host) # => nil'
          end
          def host_uptime_seconds(host)
            host&.uptime_seconds
          end

          apipie :method, 'Returns amount of memory allocated for the given host' do
            required :host, 'Host::Managed', desc: 'host object for which the amount is returned'
            returns Integer, desc: 'amount of memory in megabytes'
            example 'host_memory(host) # => 11853'
          end
          def host_memory(host)
            host&.ram
          end

          apipie :method, 'Returns amount of sockets on the given host' do
            required :host, 'Host::Managed', desc: 'host object for which the amount is returned'
            returns Integer, desc: 'amount of sockets'
            example 'host_sockets(host) # => 2'
          end
          def host_sockets(host)
            host&.sockets
          end

          apipie :method, 'Returns amount of cores on the given host' do
            required :host, 'Host::Managed', desc: 'host object for which the amount is returned'
            returns Integer, desc: 'amount of cores'
            example 'host_cores(host) # => 2'
          end
          def host_cores(host)
            host&.cores
          end

          apipie :method, 'Returns true if the given host is virtual, false otherwise' do
            required :host, 'Host::Managed', desc: "host object to check if it's virtual"
            returns one_of: [true, false]
            example 'host_virtual(host) # => true'
          end
          def host_virtual(host)
            host&.virtual
          end

          apipie :method, 'Compares two package versions' do
            desc 'It can be used to compare RPM or DEB package versions but it will not handle edge cases (e.g. 1.0.0.pre1-snapshot-1)'
            required :first, String, desc: 'first package version'
            required :second, String, desc: 'second package version'
            returns Integer, desc: 'returns 1 if the first version is greater, -1 if the second one and 0 if versions are the same'
            example 'gem_version_compare("10.2.3", "2.0.1") #=> 1'
            example 'gem_version_compare("1.2.3", "1.2.4") #=> -1'
            example 'gem_version_compare("1.2.3", "1.2.3") #=> 0'
          end
          def gem_version_compare(first, second)
            Gem::Version.new(first.to_s) <=> Gem::Version.new(second.to_s)
          end

          apipie :method, "Returns the TLS certificate(s) needed to verify a connection to Foreman" do
            desc 'Currently it relies on "SSL CA file" and "Server CA file" authentication settings, which normally points to the file containing the
              CA certificate for Smart Proxies. However in the default deployment, this certificate happens to be the same.'
            example "SSL_CA_CERT=$(mktemp)
                     cat > $SSL_CA_CERT <<CA_CONTENT
                     <%= foreman_server_ca_cert %>
                     CA_CONTENT
                     curl --cacert $SSL_CA_CERT https://foreman.example.com"
          end
          def foreman_server_ca_cert(server_ca_file_enabled: true, ssl_ca_file_enabled: true)
            setting_values = []
            setting_values << Setting[:server_ca_file] if server_ca_file_enabled
            setting_values << Setting[:ssl_ca_file] if ssl_ca_file_enabled

            raise UndefinedSetting.new(setting: '"Server CA file" or "SSL CA file"') if setting_values.reject(&:empty?).empty?

            files_content = setting_values.uniq.compact.map do |setting_value|
              File.read(setting_value)
            rescue StandardError => e
              Foreman::Logging.logger('templates').warn("Failed to read CA file: #{e}")

              nil
            end

            result = files_content.compact.join("\n")

            msg = N_("SSL CA file not found, check the 'Server CA file' and 'SSL CA file' in Settings > Authentication")
            raise Foreman::Exception.new(msg) unless result.present?

            result
          end

          apipie_method :rand, 'Returns random floating point numbers between 0 and 1' do
            desc 'When the attribute is smaller or equal to 1, the function return float. Otherwise it returns integer. '
            optional :args, ::Float, desc: 'Can take a parameter as max value for random number. For negative and float numbers produce interesting outputs'
            returns ::Float
            example 'rand #=> 0.5
                     rand #=> 0.8
                     rand(100) #=> 23
                     rand(100) #=> 72'
          end

          apipie :method, "Return the concatenated array with correct line break" do
            desc 'This method returns concatenated array with correct line break with the respect of output format.
                  For HTML output, it joins array members with <br> tag otherwise it uses a \n character.
                  It works as new line at CSV but at YAML and JSON it is used for separating of lines
                  because of structure of these formats'
            required :array, Array, desc: 'Array of values to concatenate'
            returns ::String
            example "join_with_line_break(values) # => 1<br>2<br>3 for HTML"
            example 'join_with_line_break(values) # => 1\n2\n3 for CSV,JSON,YAML'
          end
          def join_with_line_break(array)
            case report_format.mime_type
            when 'text/csv'
              array.join("\n")
            when 'application/json', 'text/yaml'
              array.join("\\n")
            when 'text/html'
              array.map! { |str| CGI.escapeHTML(str) }
              array.join("<br>").html_safe
            end
          end

          apipie :method, 'Returns previous revision of a record as tracked in the audit' do
            desc 'Returns the same object if there is no previous revision'
            required :record, ApplicationRecord, desc: 'Record to get previous revision for'
            returns ApplicationRecord
            raises error: Foreman::Exception, desc: 'when the provided record is not auditable'
            example 'previous_revision(host_with_new_name).name # => "previous-name"'
          end
          def previous_revision(record)
            record.revision(:previous)
          rescue NoMethodError => e
            Foreman::Logging.logger('templates').error(e)
            raise Foreman::Exception.new(_('%s is not auditable') % record.class)
          end

          apipie :method, 'Returns a short version of Foreman' do
            desc 'Returns a string representing the short version (X.Y) of Foreman'
            returns String
            example 'foreman_short_version # => "3.4"'
          end
          def foreman_short_version
            Foreman::Version.new.short
          end

          private

          def validate_subnet(subnet)
            raise WrongSubnetError.new(object_name: subnet.to_s, object_class: subnet.class.to_s) unless subnet.is_a?(Subnet)
          end
        end
      end
    end
  end
end
