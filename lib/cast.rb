class Cast
  def self.to_bool(value)
    case value

      when String
        return true if value =~ (/(true|t|yes|y|1)$/i)
        return false if value.blank? || value =~ (/(false|f|no|n|0)$/i)

      when Fixnum
        return true if value == 1
        return false if value == 0

      when NilClass
        return false

      else
        return value
    end
  end
end