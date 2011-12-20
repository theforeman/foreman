require "net/validations"

module Net
  class Record
    include Net::Validations
    attr_accessor :hostname, :proxy, :logger

    def initialize opts = {}
      # set all attributes
      opts.each do |k,v|
        eval("self.#{k}= v") if self.respond_to?("#{k}=")
      end if opts
      self.logger ||= Rails.logger
      raise "Must define a hostname" if hostname.blank?
      raise "Must define a proxy"    if proxy.nil?
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
    def == other
      return false unless other.respond_to? :attrs
      self.attrs == other.attrs
    end

  end

  class Error < RuntimeError; end

  class Conflict < Exception
    attr_accessor :type, :expected, :actual, :message
  end
end
