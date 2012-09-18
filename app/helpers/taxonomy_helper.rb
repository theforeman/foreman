module TaxonomyHelper
  def show_location_tab?
    SETTINGS[:locations_enabled] && (User.current.admin? || authorized_keys(:locations, :index))
  end

  def show_organization_tab?
    SETTINGS[:tenants_enabled] && (User.current.admin? || authorized_keys(:organizations, :index))
  end

  def show_taxonomy_tabs?
    SETTINGS[:locations_enabled] or SETTINGS[:tenants_enabled]
  end
end
