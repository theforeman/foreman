require_dependency "net/validations"

module Net
  class Record
    attr_accessor :hostname, :proxy, :logger

    def initialize(opts = {})
      # set all attributes
      opts&.each do |k, v|
        send("#{k}=", v) if respond_to?("#{k}=")
      end

      self.logger ||= Rails.logger
      raise "Must define a proxy" if proxy.nil?
    end

    def inspect
      to_s
    end

    # Do we have conflicting entries?
    def conflicting?
      !conflicts.empty?
    end

    # clears internal cache
    def reload!
      @conflicts = nil
    end

    # Compares two records by their attributes
    def ==(other)
      return false unless other.respond_to? :attrs
      attrs == other.attrs
    end
  end

  class Error < RuntimeError; end

  class Conflict < RuntimeError
    attr_accessor :type, :expected, :actual, :message
  end
end
