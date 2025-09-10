class QueryBuilder
  class << self
    def parenthesize(string, always: false)
      if string.blank? || (!always && (string.start_with?('(') && string.end_with?(')')))
        string
      else
        '(' + string + ')'
      end
    end

    def join(conjunction, parts)
      parts.reject!(&:blank?)
      parts.map! { |s| parenthesize(s) } if parts.size > 1
      parenthesize(parts.join(" #{conjunction} ").presence, always: true)
    end

    def key_value_in(key, values, on_empty = :nil)
      values.reject!(&:blank?)
      return "#{key} ^ (#{values.join(',')})" if values.any?

      case on_empty
      when :nil
        nil
      when :block
        parenthesize("set? #{key} AND null? #{key}")
      else
        raise ArgumentError
      end
    end
  end
end
