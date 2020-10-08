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
        end
      end
    end
  end
end
