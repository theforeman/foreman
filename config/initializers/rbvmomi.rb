# Workaround for #2680, where our ComputeResource is being loaded by RbVmomi
# instead of its own.
#
# RbVmomi performs deserialization of XML representing VMware objects into
# Ruby objects, but one of these is also called ComputeResource.  If our
# ComputeResource is loaded first, then Ruby's class loader prefers the
# top-level ::ComputeResource instead of RbVmomi::VIM::ComputeResource.
# Therefore, this initializer must run before Rails' eager class loading.
#
# To top it off, RbVmomi's class loading relies on overriding
# const_missing/method_missing to set appropriate class ancestors,
# so simply calling the constant the way they intended seems to be the
# most reliable way to get it loaded.

if defined? ComputeResource
  puts "Workaround for RbVmomi may not work as ComputeResource is already loaded: #{ComputeResource}"
end

begin
  RbVmomi::VIM::ComputeResource
rescue NameError
  # rbvmomi might not be installed
end
