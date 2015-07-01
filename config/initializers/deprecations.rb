module Deprecations
  def const_missing(const_name)
    return(super) unless const_name.to_s == 'ConfigTemplate'
    Foreman::Deprecation.deprecation_warning('1.11', 'Config templates were renamed to provisioning templates')
    ::ProvisioningTemplate
  end
end

Object.extend(Deprecations)
