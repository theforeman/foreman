Rails.application.config.to_prepare do
  # Puppet, the default parser
  Foreman::Plugin.fact_importer_registry.register(:puppet, PuppetFactImporter, true)
  Foreman::Plugin.fact_parser_registry.register(:puppet, PuppetFactParser, true)

  # Ansible
  Foreman::Plugin.fact_importer_registry.register(:ansible, ForemanAnsible::StructuredFactImporter)
  Foreman::Plugin.fact_parser_registry.register(:ansible, AnsibleFactParser)

  # Katello
  Foreman::Plugin.fact_importer_registry.register(Katello::RhsmFactName::FACT_TYPE, Katello::RhsmFactImporter)
  Foreman::Plugin.fact_parser_registry.register(Katello::RhsmFactName::FACT_TYPE, Katello::RhsmFactParser)

  # Chef
  Foreman::Plugin.fact_importer_registry.register(:foreman_chef, ForemanChef::FactImporter)
  Foreman::Plugin.fact_parser_registry.register(:foreman_chef, ForemanChef::FactParser)

  # Salt
  Foreman::Plugin.fact_importer_registry.register(:foreman_salt, ForemanSalt::FactImporter)
  Foreman::Plugin.fact_parser_registry.register(:foreman_salt, ForemanSalt::FactParser)
end
