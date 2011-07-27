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

  def to_param
    name
  end

end

# workaround for puppet bug http://projects.reductivelabs.com/issues/3949
if Facter.puppetversion == "0.25.5"
  begin
    require 'RRDtool'
  rescue LoadError
    nil
  end
end
