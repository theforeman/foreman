module SmartProxyHostExtensions
  extend ActiveSupport::Concern

  module ClassMethods
    # registers a reference to a proxy
    def smart_proxy_reference(hash)
      ProxyReferenceRegistry.add_smart_proxy_reference hash
    end

    def smart_proxy_ids(hosts_scope = Host::Managed.where(nil))
      hosts_scope.eager_load(proxy_join_tables).pluck(proxy_column_list).flatten.uniq.compact
    end

    # table names containing reference to a proxy
    def proxy_join_tables
      proxy_join_references.map(&:join_relation)
    end

    # list of db column names that are used as a reference to a proxy
    def proxy_column_list
      columns = proxy_reference_groups_by_table.map do |table_name, reference_group|
        reference_group.flat_map.with_index do |ref, idx|
          ref.map_column_names idx
        end
      end
      columns.flatten.concat(proxy_self_columns).join(',')
    end

    private

    def proxy_self_columns
      proxy_self_references.map(&:columns_to_s)
    end

    def proxy_reference_groups_by_table
      proxy_join_references_with_reflection.group_by(&:table_name).with_indifferent_access
    end

    def proxy_join_references_with_reflection
      proxy_join_references.select(&:valid?)
    end

    def proxy_join_references
      ProxyReferenceRegistry.smart_proxy_references.select(&:join?)
    end

    def proxy_self_references
      ProxyReferenceRegistry.smart_proxy_references.reject(&:join?)
    end
  end
end
