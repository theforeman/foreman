module Foreman
  module Renderer
    module Scope
      module Macros
        module Loaders
          include Foreman::Renderer::Errors
          extend ApipieDSL::Class

          apipie :class, desc: 'Loader macros to use within a template' do
            name 'Loaders'
            sections only: %w[all reports]
          end

          apipie :param_group, name: :load_resource_keywords do
            keyword :search, String, desc: 'A search term to limit the resulting collection, using standard search syntax', default: ''
            keyword :includes, Array, of: [String, Symbol], desc: 'An array of associations represented by strings or symbols, to be included in the SQL query. The list can be extended
              from plugins and can not be fully documented here. Most used associations are :puppetclasses, :host_statuses, :fact_names, :interfaces, :domain, :subnet', default: nil
            keyword :preload, Array, desc: 'Same as includes but using preload', default: nil
            keyword :joins, Array, desc: 'An array of associations represented by strings or symbols, to be included in the SQL query. The list can be extended from plugins and can not be
              fully documented here. Joined associations can be then used in select keyword and will be loaded into instantiated object', default: nil
            keyword :select, Array, desc: 'An array of columns (object attributes) to be loaded. By default, all columns are loaded, however you may specify subset of columns you need', default: nil
          end

          LOADERS = [
            [:load_organizations, Organization, :view_organizations],
            [:load_locations, Location, :view_locations],
            [:load_hosts, Host, :view_hosts],
            [:load_operating_systems, Operatingsystem, :view_operatingsystems],
            [:load_subnets, Subnet, :view_subnets],
            [:load_smart_proxies, SmartProxy, :view_smart_proxies],
            [:load_user_groups, Usergroup, :view_usergroups],
            [:load_host_groups, Hostgroup, :view_hostgroups],
            [:load_domains, Domain, :view_domains],
            [:load_realms, Realm, :view_realms],
            [:load_users, User, :view_users],
          ]

          LOADERS.each do |name, model, permission|
            apipie :method, "Loads #{model} objects" do
              desc "This macro returns a collection of #{model.to_s.pluralize} matching search criteria.
                The collection is limited to what objects the current user is authorized to view by #{permission} permission. Also it's loaded in bulk
                of 1 000 records."
              param_group :load_resource_keywords
              returns array_of: model, desc: 'The collection that can be iterated over using each_record'
              example "<% #{name}.each_record do |#{model.to_s.downcase}| %>
  <%= #{model.to_s.downcase}.id %>, <%= #{model.to_s.downcase}.#{model == User ? 'login' : 'name'} %>
<% end %>", desc: "Prints #{model.to_s.downcase} id and #{model == User ? 'login' : 'name'} of each #{model.to_s.downcase}"
              example_for :load_hosts, "<% load_hosts(search: 'domain = example.com', includes: [ :interfaces ]).each_record do |host| %>
  <%= host.name %>, <%= host.interfaces.map { |i| i.mac }.join(', ') %>
<% end %>", desc: 'Prints host name and MACs of each host'
              example_for :load_users, "<% load_users(search: 'location = Europe', includes: :auth_source).each_record do |user| %>
  <%= user.login %>, <%= user.last_login_on %>, <%= user_auth_source_name(user) %>
<% end %>", desc: "Prints users in Europe, their login, when a user was logged on for the last time and the authentication source"
            end
            define_method name do |search: '', includes: nil, preload: nil, joins: nil, select: nil, batch: 1_000, limit: nil|
              load_resource(klass: model, search: search, permission: permission, includes: includes, preload: preload, joins: joins, select: select, batch: batch, limit: limit)
            end
          end

          private

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
