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
    text = Organization.current.nil? ? _("Any Organization") : Organization.current.to_label
    if count == 1 && !User.current.admin?
      link_to text, "#"
    else
      link_to(text, "#", :class => "dropdown-toggle", :'data-toggle'=>"dropdown")
    end
  end

  def location_dropdown count
      text = Location.current.nil? ? _("Any Location") : Location.current.to_label
      if count == 1 && !User.current.admin?
        link_to text, "#"
      else
        link_to(text, "#", :class => "dropdown-toggle", :'data-toggle'=>"dropdown")
      end
  end

  def taxonomies_plural
    controller_name
  end

  def taxonomy_single
    controller_name.singularize
  end

  def taxonomy_upcase
    controller_name.humanize.titleize
  end

  def wizard_header(current, *args)
    content_tag(:ul,:class=>"wizard") do
      step=1
      content = nil
      args.each do |arg|
        step_content = content_tag(:li,(content_tag(:span,step,:class=>"badge" +" #{'badge-inverse' if step==current}")+arg).html_safe, :class=>"#{'active' if step==current}")
        step == 1 ? content = step_content : content += step_content
        step += 1
      end
      content
    end
  end

  def option_button text, href, options
    field(nil, "", options) do
      link_to(text, href, options)
    end
  end

  def is_location?
    controller_name == "locations"
  end

  def edit_taxonomy_path(taxonomy)
    is_location? ? edit_location_path(taxonomy) : edit_organization_path(taxonomy)
  end

  def hash_for_edit_taxonomy_path(taxonomy)
    is_location? ? hash_for_edit_location_path(:id => taxonomy) : hash_for_edit_organization_path(:id => taxonomy)
  end

  def hash_for_clone_taxonomy_path(taxonomy)
    is_location? ? hash_for_clone_location_path(:id => taxonomy) : hash_for_clone_organization_path(:id => taxonomy)
  end

  def hash_for_taxonomy_path(taxonomy)
    is_location? ? hash_for_location_path(:id => taxonomy) : hash_for_organization_path(:id => taxonomy)
  end

  def hash_for_new_taxonomy_path
    is_location? ? hash_for_new_location_path : hash_for_new_organization_path
  end

  def mismatches_taxonomies_path
    is_location? ? mismatches_locations_path : mismatches_organizations_path
  end

  def import_mismatches_taxonomy_path taxonomy
    is_location? ? import_mismatches_location_path(taxonomy) : import_mismatches_organization_path(taxonomy)
  end

  def assign_all_hosts_taxonomy_path(taxonomy)
    is_location? ? assign_all_hosts_location_path(taxonomy) : assign_all_hosts_organization_path(taxonomy)
  end

  def assign_hosts_taxonomy_path(taxonomy)
    is_location? ? assign_hosts_location_path(taxonomy) : assign_hosts_organization_path(taxonomy)
  end

  def taxonomy_ids_sym
    is_location? ? :location_ids : :organization_ids
  end

end
