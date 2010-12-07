require 'rubygems'

require 'ruby2ruby'
begin
  require 'ruby_parser' # try to load RubyParser and use it if present
rescue LoadError => e
end
# this doesn't work somehow. Maybe something changed inside
# ParseTree or sexp_processor or so.
# (the require itself works, but ParseTree doesn't play nice)
# begin
#   require 'parse_tree'
# rescue LoadError => e
# end

require 'safemode/core_ext'
require 'safemode/blankslate'
require 'safemode/exceptions'
require 'safemode/jail'
require 'safemode/core_jails'
require 'safemode/parser'
require 'safemode/scope'

module Safemode
  class << self
    def jail(obj)
      find_jail_class(obj.class).new obj
    end
    
    def find_jail_class(klass)
      while klass != Object
        return klass.const_get('Jail') if klass.const_defined?('Jail')
        klass = klass.superclass
      end
      Jail
    end
  end
    
  define_core_jail_classes
  
  class Box
    def initialize(delegate = nil, delegate_methods = [], filename = nil, line = nil)
      @scope = Scope.new(delegate, delegate_methods)
      @filename = filename
      @line = line
    end    

    def eval(code, assigns = {}, locals = {}, &block)
      code = Parser.jail(code)
      binding = @scope.bind(assigns, locals, &block)
      result = Kernel.eval(code, binding, @filename || __FILE__, @line || __LINE__)
    end
    
    def output
      @scope.output
    end 
  end
end
