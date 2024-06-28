# stdlib dependencies
require 'English'

# Registries from app/registries/ that do not create a namespace
# should be loaded manually due to Zeitwerk
require 'foreman/access_permissions'
require 'foreman/settings'

Rails.application.config.before_initialize do
  # load topbar
  Menu::Loader.load
end

Foreman::Plugin.initialize_default_registries

Rails.application.config.after_initialize do
  Foreman.settings.load_values unless Foreman.in_setup_db_rake? || !(Setting.table_exists? rescue false)
end

Rails.application.config.to_prepare do
  Foreman::Plugin.report_scanner_registry.register_report_scanner ReportScanner::PuppetReportScanner
  Foreman::Plugin.medium_providers_registry.register MediumProviders::Default
  # clear our users topbar cache
  # The users table may not be exist during initial migration of the database
  TopbarSweeper.expire_cache_all_users if (User.table_exists? rescue false)

  Foreman.settings.load if (Setting.table_exists? rescue(false)) && !Foreman.in_setup_db_rake?

  Facets.register(HostFacets::ReportedDataFacet, :reported_data) do
    api_view({ :list => 'api/v2/hosts/reported_data' })
    set_dependent_action :destroy
    template_compatibility_properties :cores, :virtual, :sockets, :ram, :uptime_seconds
  end
  Facets.register(HostFacets::InfrastructureFacet, :infrastructure_facet) do
    api_view({ :list => 'api/v2/hosts/infrastructure_facet' })
    set_dependent_action :destroy
  end

  Facets.register(ForemanRegister::RegistrationFacet, :registration_facet) do
    set_dependent_action :destroy
  end

  Foreman::Plugin.all.each do |plugin|
    plugin.to_prepare_callbacks.each(&:call)
  end

  Foreman::Plugin.graphql_types_registry.realise_extensions unless Foreman.in_setup_db_rake?

  Foreman.input_types_registry.register(InputType::UserInput)
  Foreman.input_types_registry.register(InputType::FactInput)
  Foreman.input_types_registry.register(InputType::VariableInput)

  ReportImporter.register_smart_proxy_feature("Puppet")
end

# Preload here all classes which use Foreman::STI and using registration methods
# E.g. Base.register_type(BMC)
# Some constants that use such classes may be defined before all the related classes/models are loaded and registered
# E.g. InterfaceTypeMapper::ALLOWED_TYPE_NAMES
Rails.application.reloader.to_prepare do
  Nic::Base.register_type(Nic::Managed)
  Nic::Base.register_type(Nic::BMC)
  Nic::Base.register_type(Nic::Bond)
  Nic::Base.register_type(Nic::Bridge)
end
