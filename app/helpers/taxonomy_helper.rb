module TaxonomyHelper
  def show_location_tab?
    SETTINGS[:locations_enabled] && User.current.allowed_to?(:view_locations)
  end

  def show_organization_tab?
    SETTINGS[:organizations_enabled] && User.current.allowed_to?(:view_organizations)
  end

  def show_taxonomy_tabs?
    SETTINGS[:locations_enabled] or SETTINGS[:organizations_enabled]
  end

  def show_add_location_button? count
    count ==0 && User.current.allowed_to?(:create_locations)
  end

  def show_add_organization_button? count
    count == 0 && User.current.allowed_to?(:create_organizations)
  end

  def organization_dropdown count
    text = Organization.current.nil? ? "Any Organization" : Organization.current.to_label
    if count == 1 && !User.current.admin?
      link_to text, "#"
    else
      link_to(text, "#", :class => "dropdown-toggle", :'data-toggle'=>"dropdown")
    end
  end

  def location_dropdown count
      text = Location.current.nil? ? "Any Location" : Location.current.to_label
      if count == 1 && !User.current.admin?
        link_to text, "#"
      else
        link_to(text, "#", :class => "dropdown-toggle", :'data-toggle'=>"dropdown")
      end
    end
end
