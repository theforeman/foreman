Foreman::Plugin.fact_importer_registry.register(:puppet, PuppetFactImporter, true)
FactParser.register_fact_parser :puppet, PuppetFactParser, true

# The module should be included after the class is constructed,
# since it tries to alias_method_chain a method that is defined
# in the class itself.
Host::Managed.prepend PuppetHostExtensions
