# Do not use - these settings are now in Setting::Configuration, but this model
# has to stay in order to be able to migrate them
class Setting::Puppet < Setting
  def self.load_defaults
    true
  end
end
