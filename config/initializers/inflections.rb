# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format
# (all these examples are active by default):
ActiveSupport::Inflector.inflections do |inflect|
  # inflect.plural /^(ox)$/i, '\1en'
  # inflect.singular /^(ox)en/i, '\1'
  # inflect.irregular 'person', 'people'
  # inflect.uncountable %w( fish sheep )
  inflect.singular /^puppetclass$/, 'puppetclass'
  inflect.singular /^Puppetclass$/, 'Puppetclass'
  inflect.singular /^HostClass$/, 'HostClass'
  inflect.singular /^host_class$/, 'host_class'
  inflect.singular /^HostgroupClass$/, 'HostgroupClass'
  inflect.singular /^hostgroup_class$/, 'hostgroup_class'
end
