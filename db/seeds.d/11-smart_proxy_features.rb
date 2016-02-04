def seed_smart_proxy_features
  # Proxy features [name, priority]
  [
    ["DHCP", 1000],
    ["DNS", 2000],
    ["TFTP", 3000],
    ["Puppet", 4000],
    ["Puppet CA", 5000],
    ["Facts", 6000],
    ["Realm", 7000],
    ["BMC", 8000],
    ["Templates", 9000],
    ["Logs", 10000],
  ].each do |name_priority|
    name = name_priority[0]
    priority = name_priority[1]
    f = Feature.where(:name => name).first_or_create
    raise "Unable to create proxy feature: #{format_errors f}" if f.nil? || f.errors.any?
    # reset default priority each seed
    if f.respond_to? :priority
      f.priority = priority
      f.save
      raise "Unable to set proxy feature priority: #{format_errors f}" if f.nil? || f.errors.any?
    end
  end
end
