# initialize puppet related pagelets
Pagelets::Manager.with_key "hosts/_form" do |mgr|
  mgr.add_pagelet :main_tab_fields,
    :partial => "hosts/puppet/main_tab_fields",
    :priority => 100
end

Foreman::Plugin.fact_importer_registry.register(:puppet, PuppetFactImporter, true)
FactParser.register_fact_parser :puppet, PuppetFactParser, true

# The module should be included after the class is constructed,
# since it tries to alias_method_chain a method that is defined
# in the class itself.
Host::Managed.prepend PuppetHostExtensions

Rails.application.config.to_prepare do
  Foreman.input_types_registry.register(InputType::PuppetParameterInput)
end
