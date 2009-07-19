module ActiveSupport
  module Dependencies
    extend self
    
    #def load_missing_constant(from_mod, const_name)
    
    def forgiving_load_missing_constant( from_mod, const_name )
      begin
        old_load_missing_constant(from_mod, const_name)
      rescue ArgumentError => arg_err
        if arg_err.message == "#{from_mod} is not missing constant #{const_name}!"
          return from_mod.const_get(const_name)
        else
          raise
        end
      end
    end
    alias :old_load_missing_constant :load_missing_constant
    alias :load_missing_constant :forgiving_load_missing_constant
  end
end