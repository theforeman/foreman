Rails.application.config.to_prepare do
  # Preload all classes which use Foreman::STI and using registration methods
  # E.g. Base.register_type(BMC)
  # Some constants that use such classes may be defined before all the related classes/models are loaded and registered
  # E.g. InterfaceTypeMapper::ALLOWED_TYPE_NAMES
  Rails.autoloaders.main.eager_load_dir("#{Rails.root}/app/models/nic")
end
