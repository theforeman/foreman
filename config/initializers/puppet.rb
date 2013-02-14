require 'active_support/dependencies'
ActiveSupport::Dependencies.unhook!

require 'puppet'
require 'puppet/rails'

ActiveSupport::Dependencies.hook!

if Puppet::PUPPETVERSION.to_i < 3
  Puppet.parse_config
end

$puppet = Puppet.settings.instance_variable_get(:@values) if Rails.env == "test"

# workaround for puppet bug http://projects.reductivelabs.com/issues/3949
if Facter.puppetversion == "0.25.5"
  begin
    require 'RRDtool'
  rescue LoadError
    nil
  end
end
