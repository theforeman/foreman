Rails.application.config.to_prepare do
  # Puppet, the default parser
  Foreman::Plugin.fact_parser_registry.register(:puppet, FactParsers::Puppet, true)

  # Ansible
  Foreman::Plugin.fact_parser_registry.register(:ansible, FactParsers::Ansible)

  # Katello
  Foreman::Plugin.fact_parser_registry.register(FactNames::Rhsm::FACT_TYPE, FactParsers::Rhsm)

  # Chef
  Foreman::Plugin.fact_parser_registry.register(:foreman_chef, FactParsers::Chef)

  # Salt
  Foreman::Plugin.fact_parser_registry.register(:foreman_salt, FactParsers::Salt)
end
