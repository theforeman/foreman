module ScopedSearchExtensions
  extend ActiveSupport::Concern

  module ClassMethods
    def value_to_sql(operator, value)
      return value                 if operator !~ /LIKE/i
      return value.tr_s('%*', '%') if (value =~ /%|\*/)
      "%#{value}%"
    end

    def cast_facts(key, operator, value)
      is_int = (value =~ /\A[-+]?\d+\z/ ) || (value.is_a?(Integer))
      is_pg = ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'postgresql'
      # Once Postgresql 8 support is removed (used in CentOS 6), this could be replaced to only keep the first form (working well with PG 9)
      if (is_int && !is_pg)
        casted = "CAST(fact_values.value AS DECIMAL) #{operator} #{value}"
      elsif (is_int && is_pg)
        casted = "fact_values.value ~ E'^\\\\d+$' AND CAST(fact_values.value AS DECIMAL) #{operator} #{value}"
      else
        casted = "fact_values.value #{operator} '#{value}'"
      end
      casted
    end
  end
end
