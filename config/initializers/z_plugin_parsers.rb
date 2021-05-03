class ParserRegistrator
  def self.register_fact_parser(type, parser)
    if (old_parser = FactParser.parser_for(type)) && old_parser != FactParser.parsers.default
      Rails.logger.warn("WARNING: Parser #{old_parser} for type #{type} is replaced with #{parser}")
    end

    FactParser.register_fact_parser(type, parser)
  end
end

# Ansible
Foreman::Plugin.fact_importer_registry.register(:ansible, ForemanAnsible::StructuredFactImporter, false)
ParserRegistrator.register_fact_parser(:ansible, AnsibleFactParser)
