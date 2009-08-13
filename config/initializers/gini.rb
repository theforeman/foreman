require 'puppet'

Puppet[:config] = "/etc/puppet/puppet.conf"
Puppet.parse_config

$GINIHOST = Facter.fqdn
# import settings file
$settings = YAML.load_file("#{RAILS_ROOT}/config/settings.yaml")
# Add an empty method to nil. Now no need for if x and x.empty?. Just x.empty?
class NilClass
  def empty?
    true
  end
end

class ActiveRecord::Base
  private
  def ensure_not_used
    self.hosts.each do |host|
      errors.add_to_base to_label + " is used by " + host.hostname
    end
    raise ApplicationController::InvalidDeleteError.new, errors.full_messages.join("<br>") unless errors.empty?
    true
  end
end
