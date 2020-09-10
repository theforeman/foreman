# this makes sure that hash with indifferent access gets deep converted into hash.
# code borrowed from 4.2 ActiveSupport
module ActiveSupport
  class HashWithIndifferentAccess < Hash
    def deep_to_hash
      new_hash = Hash.new(default)
      each do |key, value|
        new_hash[key] = deep_convert_value(value, :for => :to_hash)
      end
      new_hash
    end

    def deep_convert_value(value, options = {})
      if value.is_a? HashWithIndifferentAccess
        if options[:for] == :to_hash
          value.deep_to_hash
        else
          value.nested_under_indifferent_access
        end
      elsif value.is_a?(Array)
        value = value.dup unless options[:for] == :assignment
        value.map! { |e| deep_convert_value(e, options) }
      else
        value
      end
    end
  end
end
