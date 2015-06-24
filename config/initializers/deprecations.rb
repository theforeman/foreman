module Deprecations
  def const_missing(const_name)
    return(super) unless const_name.to_s == 'ConfigTemplate'
    warn '`ConfigTemplate` has been deprecated. Use `ProvisioningTemplate` instead.'
    ::ProvisioningTemplate
  end
end

Object.extend(Deprecations)
