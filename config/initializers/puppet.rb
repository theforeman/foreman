Foreman::Plugin.fact_importer_registry.register(:puppet, PuppetFactImporter, true)
FactParser.register_fact_parser :puppet, PuppetFactParser, true
