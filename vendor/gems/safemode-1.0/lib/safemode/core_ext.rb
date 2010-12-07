module Kernel  
  def silently(&blk)
    old_verbose, $VERBOSE = $VERBOSE, nil
    yield
    $VERBOSE = old_verbose
  end   
end

class Module  
  def undef_methods(*methods)
    methods.each { |name| undef_method(name) }
  end
end

class Object
  def to_jail
    Safemode.jail self
  end
end

# As every call to an object in the eval'ed string will be jailed by the
# parser we don't need to "proactively" jail arrays and hashes. Likewise we
# don't need to jail objects returned from a jail. Doing so would provide
# "double" protection, but it also would break using a return value in an if
# statement, passing them to a Rails helper etc.

# class Array
#   def to_jail
#     Safemode.jail collect{ |obj| obj.to_jail }
#   end
# end
# 
# class Hash
#   def to_jail
#     hash = {}
#     collect{ |key, obj| hash[key] = obj.to_jail}
#     Safemode.jail hash
#   end
# end