# https://rails.lighthouseapp.com/projects/8994/tickets/1812-default#ticket-1812-46efault_scope
#
# Allows ActiveRecord::Base.default_scope to take in a proc
# This should be removed after upgrading rails to >= 3.0.x
module ActiveRecord
  class Base
    class << self
      protected
        def current_scoped_methods #:nodoc
          method = scoped_methods.last
          if method.respond_to?(:call)
            unscoped(&method)
          else
            method
          end
        end
    end
  end
end
