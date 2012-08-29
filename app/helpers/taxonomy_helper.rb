module TaxonomyHelper
  def show_location_tab?
    SETTINGS[:locations_enabled] && (User.current.admin? || authorized_keys(:locations, :index))
  end

  def show_tenant_tab?
    SETTINGS[:tenants_enabled] && (User.current.admin? || authorized_keys(:tenants, :index))
  end

  def show_taxonomy_tabs?
    SETTINGS[:locations_enabled] or SETINGS[:tenants_enabled]
  end
end
