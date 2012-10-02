# This unfortunately has to get called before the "require 'puppet'".
require 'active_support/dependencies'
module ActiveSupport
  module Dependencies
    def unhook!
    end
  end
end

require 'puppet'
require 'puppet/rails'
$puppet = Puppet.settings.instance_variable_get(:@values) if Rails.env == "test"

class Resource < Puppet::Rails::Resource
end
class SourceFile < Puppet::Rails::SourceFile
end
class ResourceTag < Puppet::Rails::ResourceTag
end
class ParamValue < Puppet::Rails::ParamValue
end

# We reopen the class and add the associations here as we canot subclass it in app/models as this breaks puppet internals
class Puppet::Rails::FactName
  has_many :user_facts
  has_many :users, :through => :user_facts

  scope :no_timestamp_fact, :conditions => ["fact_names.name <> ?",:_timestamp]
  scope :timestamp_facts,   :conditions => ["fact_names.name = ?", :_timestamp]

  default_scope :order => 'LOWER(fact_names.name)'

  def to_param
    name
  end

end

FactName = Puppet::Rails::FactName

# workaround for puppet bug http://projects.reductivelabs.com/issues/3949
if Facter.puppetversion == "0.25.5"
  begin
    require 'RRDtool'
  rescue LoadError
    nil
  end
end
