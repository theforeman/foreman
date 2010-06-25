class Resource < Puppet::Rails::Resource
end
class SourceFile < Puppet::Rails::SourceFile
end
class ResourceTag < Puppet::Rails::ResourceTag
end
class ParamValue < Puppet::Rails::ParamValue
end

# workaround for puppet bug http://projects.reductivelabs.com/issues/3949
if Facter.puppetversion == "0.25.5"
  begin
    require 'RRDTool'
  rescue
    nil
  end
end
