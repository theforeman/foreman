module Safemode
  class Error < RuntimeError; end
  
  class SecurityError < Error
    @@types = { :const => 'constant',
                :xstr  => 'shell command',
                :fcall => 'method',
                :vcall => 'method',
                :gvar  => 'global variable' }
               
    def initialize(type, value = nil)
      type = @@types[type] if @@types.include?(type)
      super "Safemode doesn't allow to access '#{type}'" + (value ? " on #{value}" : '')
    end
  end
  
  class NoMethodError < Error
    def initialize(method, jail, source = nil)
      super "undefined method '#{method}' for #{jail}" + (source ? " (#{source})" : '')
    end
  end
end