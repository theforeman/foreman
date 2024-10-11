module ScopedSearchExtensions
  extend ActiveSupport::Concern

  module ClassMethods
    def value_to_sql(operator, value)
      return value                 if operator !~ /LIKE/i
      return value.tr_s('%*', '%') if (value =~ /%|\*/)
      escape_str_format("%#{value}%")
    end

    def escape_str_format(str)
      str.gsub('%', '%%')
    end

    def cast_facts(table, key, operator, value)
      is_int = (value =~ /\A[-+]?\d+\z/) || value.is_a?(Integer)
      is_pg = ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'postgresql'
      # Once Postgresql 8 support is removed (used in CentOS 6), this could be replaced to only keep the first form (working well with PG 9)
      if (is_int && !is_pg)
        casted = "CAST(#{table}.value AS DECIMAL) #{operator} #{value}"
      elsif (is_int && is_pg && operator !~ /LIKE/i)
        casted = "#{table}.value ~ E'^\\\\d+$' AND CAST(#{table}.value AS DECIMAL) #{operator} #{value}"
      else
        # Escape string formatting with %, as conditions will be re-sanitized through scoped_search
        casted = escape_str_format(sanitize_sql_for_conditions(["#{table}.value #{operator} ?", value_to_sql(operator, value)]))
      end
      casted
    end

    def search_cast_facts(key, operator, value)
      uniq_suffix = SecureRandom.hex(3)
      fact_names = "#{FactName.table_name}_#{uniq_suffix}"
      fact_values = "#{FactValue.table_name}_#{uniq_suffix}"

      name = key.split('.', 2).last
      name_join_conditions = sanitize_sql_for_conditions(["#{fact_names}.id = #{fact_values}.fact_name_id AND #{fact_names}.name = ?", name])
      join = "LEFT JOIN fact_values AS #{fact_values} ON #{fact_values}.host_id = hosts.id LEFT JOIN fact_names AS #{fact_names} ON #{name_join_conditions}"
      value_condition = cast_facts(fact_values, key, operator, value)
      condition = sanitize_sql_for_conditions(["#{fact_names}.name = ? AND (#{value_condition})", value_to_sql('=', name)])
      { :joins => join, :conditions => condition }
    end
  end
end
