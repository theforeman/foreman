module Safemode    
  class Jail < Blankslate 
    def initialize(source = nil)
      @source = source
    end
  
    def to_jail
      self
    end
  
    def to_s
      @source.to_s
    end
  
    def method_missing(method, *args, &block)
      unless self.class.allowed?(method)
        raise Safemode::NoMethodError.new(method, self.class.name, @source.class.name) 
      end
      
      # As every call to an object in the eval'ed string will be jailed by the
      # parser we don't need to "proactively" jail arrays and hashes. Likewise we
      # don't need to jail objects returned from a jail. Doing so would provide
      # "double" protection, but it also would break using a return value in an if
      # statement, passing them to a Rails helper etc.
      @source.send(method, *args, &block)
    end
  end
end