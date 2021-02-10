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
          def format_time(time, format: '%Y-%-m-%-d %k:%M:%S %z', zone: Time.zone)
            # if time is in float, we need to understand it as UNIX timestamp that is in UTC
            time_to_format = if (time.is_a? Float) || (time.is_a? Integer)
                               Time.zone.at(time).utc
                             else
                               time
                             end

            time_to_format.in_time_zone(zone).strftime(format)
          end
        end
      end
    end
  end
end
