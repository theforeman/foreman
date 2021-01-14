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
