module ScopedSearchExtensions
  extend ActiveSupport::Concern

  module ClassMethods
    def value_to_sql(operator, value)
      return value                 if operator !~ /LIKE/i
      return value.tr_s('%*', '%') if value.to_s.match?(/%|\*/)
      escape_str_format("%#{value}%")
    end

    def sanitize_search_condition(column, operator, value)
      if ['IN', 'NOT IN'].include?(operator.strip)
        values = value.split(',').map(&:strip)
        sanitize_sql_for_conditions(["#{column} #{operator} (?)", values])
      else
        sanitize_sql_for_conditions(["#{column} #{operator} ?", value_to_sql(operator, value)])
      end
    end

    def escape_str_format(str)
      str.gsub('%', '%%')
    end

    def cast_facts(table, key, operator, value)
      values = value.to_s.split(',').map(&:strip)
      is_int = values.all? { |item| item.match?(/\A[-+]?\d+\z/) }
      if is_int && operator !~ /LIKE/i
        sql_value = ['IN', 'NOT IN'].include?(operator.strip) ? "(#{values.join(', ')})" : value
        casted = "#{table}.value ~ E'^[-+]{0,1}\\\\d+$' AND CAST(#{table}.value AS DECIMAL) #{operator} #{sql_value}"
      else
        # Escape string formatting with %, as conditions will be re-sanitized through scoped_search
        casted = escape_str_format(sanitize_search_condition("#{table}.value", operator, value))
      end
      casted
    end
  end
end
