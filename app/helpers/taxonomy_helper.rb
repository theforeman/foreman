module TaxonomyHelper
  def show_location_tab?
    SETTINGS[:locations_enabled] && (User.current.admin? || authorized_keys(:locations, :index))
  end

  def show_tenant_tab?
    SETTINGS[:tenants_enabled] && (User.current.admin? || authorized_keys(:tenants, :index))
  end
end
