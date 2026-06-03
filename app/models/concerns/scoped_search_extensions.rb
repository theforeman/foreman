module ScopedSearchExtensions
  extend ActiveSupport::Concern

  module ClassMethods
    def value_to_sql(operator, value)
      return value                 if operator !~ /LIKE/i
      return value.tr_s('%*', '%') if value.to_s.match?(/%|\*/)
      escape_str_format("%#{value}%")
    end

    def escape_str_format(str)
      str.gsub('%', '%%')
    end

    def cast_facts(table, key, operator, value)
      is_int = value.to_s.match?(/\A[-+]?\d+\z/)
      if is_int && operator !~ /LIKE/i
        casted = "#{table}.value ~ E'^\\\\d+$' AND CAST(#{table}.value AS DECIMAL) #{operator} #{value}"
      else
        # Escape string formatting with %, as conditions will be re-sanitized through scoped_search
        casted = escape_str_format(sanitize_sql_for_conditions(["#{table}.value #{operator} ?", value_to_sql(operator, value)]))
      end
      casted
    end
  end
end
