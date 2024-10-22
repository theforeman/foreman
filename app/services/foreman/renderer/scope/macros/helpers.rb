module Foreman
  module Renderer
    module Scope
      module Macros
        module Helpers
          include Foreman::Renderer::Errors
          extend ApipieDSL::Module

          apipie :class, desc: 'Helper macros to use within a template' do
            name 'Helpers'
            sections only: %w[all]
          end

          apipie :method, "Returns counter increased by given value (as String) stored in a hostgroup param named 'sequence_num_xxx'" do
            required :hostgroup_name, String, "hostgroup title to store in (e.g. RHEL7/base)"
            optional :increment, Integer, "integer increment, can be negative too", default: 1
            optional :name, String, "name of the sequence (prefix for hostgroup parameter)", default: 'default'
            optional :prefix, Integer, "leading zeroes", default: 1
            returns String, "String with incremented value or empty string if hostgroup not found or access was denied"
            example 'sequence_hostgroup_param_next("myHG", 10) #=> 10'
            example 'sequence_hostgroup_param_next("myHG", 2, "kiosk", 5) #=> 00002'
          end
          def sequence_hostgroup_param_next(hostgroup_name, increment = 1, name = "default", prefix = 1)
            # This helper cannot be in a host-context because it was built mainly for discovery naming
            # where host-hostgroup was not yet set. This macro allows accessing hostgroup parameters
            # named starting with "sequence_num_" and increasing those counters which is not a security
            # threat.
            hostgroup = Hostgroup.find_by_title(hostgroup_name)
            raise HostgroupNotFoundError.new unless hostgroup
            result = 0
            ::Foreman::AdvisoryLockManager.with_transaction_lock("sequence_hostgroup_param_next") do
              param = GroupParameter.find_or_create_by!(name: "sequence_num_#{name}", key_type: "integer", reference_id: hostgroup.id)
              param.value ||= 0
              param.value += increment
              param.save! unless preview?
              result = param.value
            end
            "%0#{prefix}d" % result
          end

          apipie :method, "Parse the YAML document into a Ruby Hash object" do
            required :data, String
            returns Hash
            example 'parse_yaml("---\nkey: value\n") #=> {"key"=>"value"}'
          end
          def parse_yaml(data)
            YAML.safe_load(data)
          end

          apipie :method, "Parse the JSON document into a Ruby Hash object" do
            required :data, String
            returns Hash
            example 'parse_json("{\"key\":\"value\"}") #=> {"key"=>"value"}'
          end
          def parse_json(data)
            JSON.parse(data)
          end

          apipie :method, "Generate a JSON document from the Ruby Hash object" do
            required :data, Hash
            returns String
            example 'to_json({ key: :value }) #=> "{\n  \"key\": \"value\"\n}"'
          end
          def to_json(data)
            JSON.pretty_generate(data)
          end

          apipie :method, "Generate a YAML document from the Ruby Hash object" do
            required :data, Hash
            returns String
            example 'to_yaml({ key: "value" }) #=> "---\n:key: value\n"'
          end
          def to_yaml(data)
            data.to_yaml
          end

          apipie :method, "Generate a formatted time from a Ruby Time object or a Float object representing a UNIX timestamp" do
            required :time, [Float, Time], desc: 'Ruby Time object or a Float object representing a UNIX timestamp'
            optional :format, String, desc: 'Pattern to format time', default: '%Y-%-m-%-d %k:%M:%S %z'
            optional :zone, String, desc: 'This parameter can be used for specify timezone of time, for example Europe/Prague', default: 'Default local timezone'
            returns String
          end
          def format_time(time, format: '%Y-%m-%d %k:%M:%S %z', zone: Time.zone)
            # if time is in float, we need to understand it as UNIX timestamp that is in UTC
            time_to_format = if (time.is_a? Float) || (time.is_a? Integer)
                               Time.zone.at(time).utc
                             else
                               time
                             end

            time_to_format.in_time_zone(zone).strftime(format)
          end

          apipie :method, "Escape string to safely use it with a shell" do
            required :string, String, desc: 'String to escape'
            returns String
            example "shell_escape('escaped;string') #=> 'escaped\\;string'"
          end
          def shell_escape(string)
            Shellwords.shellescape(string)
          end

          apipie :method, 'Returns current date' do
            keyword :format, String, desc: 'Format string to format date according to the directives in this string', default: '%F'
            returns String
            example '<%= current_date %> #=> "2021-11-11"'
          end
          def current_date(format: '%F')
            Time.zone.today.strftime(format)
          end

          apipie :method, 'Returns current time' do
            keyword :format, String, desc: 'Format string to format time according to the directives in this string', default: '%T %z'
            returns String
            example '<%= current_time %> #=> "21:05:09 +0530"'
          end
          def current_time(format: '%T %z')
            Time.zone.now.strftime(format)
          end

          apipie :method, 'Checks whether a value is truthy or not' do
            optional :value, Object, desc: 'Value to check'
            returns one_of: [true, false], desc: 'Returns true if the value can be considered as truthy, false otherwise'
            example "truthy?(true) #=> true"
            example "truthy?(false) #=> false"
            example "truthy?('true') #=> true"
            example "truthy?('false') #=> false"
            example "truthy?(1) #=> true"
            example "truthy?(0) #=> false"
            example "truthy?('1') #=> true"
            example "truthy?('0') #=> false"
            example "truthy?('some-string') #=> false"
            example "truthy?('') #=> false"
            example "truthy?(nil) #=> false"
          end
          def truthy?(value = nil)
            Foreman::Cast.to_bool(value) == true
          end

          apipie :method, 'Checks whether a value is falsy or not' do
            optional :value, Object, desc: 'Value to check'
            returns one_of: [true, false], desc: 'Returns true if the value can be considered as falsy, false otherwise'
            example "falsy?(true) #=> false"
            example "falsy?(false) #=> true"
            example "falsy?('true') #=> false"
            example "falsy?('false') #=> true"
            example "falsy?(1) #=> false"
            example "falsy?(0) #=> true"
            example "falsy?('1') #=> false"
            example "falsy?('0') #=> true"
            example "falsy?('some-string') #=> false"
            example "falsy?('') #=> true"
            example "falsy?(nil) #=> true"
          end
          def falsy?(value = nil)
            Foreman::Cast.to_bool(value) == false
          end

          apipie :method, 'Generate a web request' do
            keyword :utility, String, desc: 'The utility to use for the web request ("curl" or "wget").'
            keyword :url, String, desc: 'The URL for the web request.'
            keyword :ssl_ca_cert, String, desc: 'The path to the SSL certificate.', default: nil
            keyword :headers, Array, of: String, desc: 'Array containing the headers for the web request starting with "--header".', default: nil
            keyword :params, Array, of: String, desc: 'Array containing the POST parameters for the web request.', default: nil
            keyword :output_file, String, desc: 'The path were the result of the web request will be stored.', default: nil
            returns String, desc: 'The web request.'
            example 'generate_web_request(utility: "curl", url: "https://www.example.com/register", ssl_ca_cert: "/etc/ssl/custom_certs/ca_cert.crt", headers: ["--header \'Authorization: Bearer <my_token>\'"], params: ["host[build]=false", "host[organization_id]=1"])'
            example 'generate_web_request(utility: "curl", url: "https://www.example.com/keys/client.asc", output_file: "/etc/apt/trusted.gpg.d/client1.asc")'
          end
          def generate_web_request(utility:, url:, ssl_ca_cert: nil, headers: nil, params: nil, output_file: nil)
            utility = Foreman.download_utilities.fetch(utility || 'curl')
            command = ["#{utility[:download_command]} #{url}"]
            command << "#{utility[:ca_cert]} #{ssl_ca_cert}" if ssl_ca_cert
            command << utility[:request_type_post] if params && utility[:request_type_post]
            if output_file
              command << "#{utility[:output_file]} #{output_file}"
            elsif utility[:output_pipe]
              command << utility[:output_pipe]
            end
            headers&.each { |header| command << header }
            utility[:format_params].call(params).each { |param| command << param } if params
            command.join(" \\\n  ")
          end
        end
      end
    end
  end
end
