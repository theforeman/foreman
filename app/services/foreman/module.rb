module Foreman
  module Module
    # This method accepts either a string or a lambda and resolves it to a constant
    def self.resolve(mod)
      mod = mod.call if mod.respond_to?(:call)
      return mod.constantize if mod.instance_of?(String)
      mod
    end
  end
end
