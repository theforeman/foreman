# OrderedHash is namespaced to prevent conflicts with other implementations
module ActiveSupport
  # Hash is ordered in Ruby 1.9!
  if RUBY_VERSION >= '1.9'
    OrderedHash = ::Hash
  else
    class OrderedHash < Hash #:nodoc:
      def initialize(*args, &block)
        super
        @keys = []
      end

      def initialize_copy(other)
        super
        # make a deep copy of keys
        @keys = other.keys
      end

      def []=(key, value)
        @keys << key if !has_key?(key)
        super
      end

      def delete(key)
        if has_key? key
          index = @keys.index(key)
          @keys.delete_at index
        end
        super
      end
      
      def delete_if
        super
        sync_keys!
        self
      end

      def reject!
        super
        sync_keys!
        self
      end

      def reject(&block)
        dup.reject!(&block)
      end

      def keys
        @keys.dup
      end

      def values
        @keys.collect { |key| self[key] }
      end

      def to_hash
        self
      end

      def each_key
        @keys.each { |key| yield key }
      end

      def each_value
        @keys.each { |key| yield self[key]}
      end

      def each
        @keys.each {|key| yield [key, self[key]]}
      end

      alias_method :each_pair, :each

      def clear
        super
        @keys.clear
        self
      end

      def shift
        k = @keys.first
        v = delete(k)
        [k, v]
      end

      def merge!(other_hash)
        other_hash.each {|k,v| self[k] = v }
        self
      end

      def merge(other_hash)
        dup.merge!(other_hash)
      end

      def inspect
        "#<OrderedHash #{super}>"
      end

    private

      def sync_keys!
        @keys.delete_if {|k| !has_key?(k)}
      end
    end
  end
end
