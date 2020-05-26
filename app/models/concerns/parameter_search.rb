module ParameterSearch
  extend ActiveSupport::Concern

  included do
    scoped_search :relation => parameter_relation_symbol, :on => :searchable_value, :in_key => parameter_relation_symbol, :on_key => :name, :rename => :params, :complete_value => true, :only_explicit => true, :operators => ['= ', '~ '], :ext_method => :search_by_params
  end

  module ClassMethods
    def search_by_params(key, operator, value)
      key_name = key.sub(/^.*\./, '')
      parameters_relation = parameter_relation_symbol

      conditions = sanitize_sql_for_conditions(
        ["parameters.name = ? and parameters.searchable_value #{operator} ?", key_name, value_to_sql(operator, value)]
      )
      build_query = unscoped
      if respond_to?(:with_taxonomy_scope)
        build_query = build_query.with_taxonomy_scope
      end
      resource_ids = build_query.joins(parameters_relation).where(conditions).distinct.pluck(:id)

      opts = "1 < 0"
      opts = "#{table_name}.id IN(#{resource_ids.join(',')})" if resource_ids.present?
      {:conditions => opts}
    end

    def parameter_relation_symbol
      case to_s
        when 'Operatingsystem' then :os_parameters
        when 'Hostgroup'       then :group_parameters
        when 'Domain'          then :domain_parameters
        when 'Subnet'          then :subnet_parameters
      end
    end
  end
end
