module Safemode
  class Scope < Blankslate
    def initialize(delegate = nil, delegate_methods = [])
      @delegate = delegate        
      @delegate_methods = delegate_methods
      @locals = {}
    end
    
    def bind(instance_vars = {}, locals = {}, &block)
      @locals = symbolize_keys(locals) # why can't I just pull them to local scope in the same way like instance_vars?
      instance_vars = symbolize_keys(instance_vars)
      instance_vars.each {|key, obj| eval "@#{key} = instance_vars[:#{key}]" }
      @_safemode_output = ''
      binding
    end
  
    def to_jail
      self
    end
    
    def puts(*args)
      print args.to_s + "\n"
    end

    def print(*args)      
      @_safemode_output += args.to_s
    end
    
    def output
      @_safemode_output
    end
    
    def method_missing(method, *args, &block)
      if @locals.has_key?(method)
        @locals[method] 
      elsif @delegate_methods.include?(method)
        @delegate.send method, *unjail_args(args), &block
      else
        raise Safemode::SecurityError.new(method, "#<Safemode::ScopeObject>")
      end
    end
    
    private
    
      def symbolize_keys(hash)
        hash.inject({}) do |hash, (key, value)| 
          hash[key.to_s.intern] = value
          hash
        end
      end
    
      def unjail_args(args)
        args.collect do |arg|        
          arg.class.name =~ /::Jail$/ ? arg.instance_variable_get(:@source) : arg
        end
      end
  end 
end
