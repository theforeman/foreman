module Foreman
  module Renderer
    module Scope
      module Macros
        module Duplicates
          include Foreman::Renderer::Errors
          extend ApipieDSL::Class

          apipie :class, desc: 'Loader macros to find duplicate records' do
            name 'Duplicate records'
            sections only: %w[reports]
          end

          apipie :method, "Return count of duplicate hosts" do
            required :attribute, String, desc: 'Attribute to group by.'
            returns Hash
            example 'duplicate_hosts("name") #=> { "hostname.example.com" => "23"}'
          end
          def duplicate_hosts(attribute)
            sanitized = ActiveRecord::Base.sanitize_sql(attribute)

            Host.authorized(:view_hosts)
                .joins(:interfaces)
                .group(sanitized)
                .having("count(*) > 1")
                .count
          end
        end
      end
    end
  end
end
