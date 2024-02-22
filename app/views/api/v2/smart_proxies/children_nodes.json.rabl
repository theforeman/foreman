@object.registered_smart_proxies.each_key do |proxy|
  attributes :"#{proxy}_id", :"#{proxy}_name"

  child proxy => proxy do
    extends "api/v2/smart_proxies/base"
  end
end
