module TaxonomyHelper
  include AncestryHelper
  include FormHelper

  def show_location_tab?
    User.current.allowed_to?(:view_locations)
  end

  def show_organization_tab?
    User.current.allowed_to?(:view_organizations)
  end

  def taxonomy_single
    _(controller_name.singularize)
  end

  def taxonomy_title
    _(controller_name.singularize.titleize)
  end

  def taxonomy_upcase
    _(controller_name.humanize.titleize)
  end

  def taxonomy_new
    is_location? ? _("New Location") : _("New Organization")
  end

  def wizard_header(current, *args)
    content_tag(:ul, :class => "wizard") do
      step = 1
      content = nil
      args.each do |arg|
        step_content = content_tag(:li, (content_tag(:span, step, :class => "badge" + " #{'badge-inverse' if step == current}") + arg).html_safe, :class => ('active' if step == current).to_s)
        (step == 1) ? content = step_content : content += step_content
        step += 1
      end
      content
    end
  end

  def option_button(text, href, options)
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

  def hash_for_nest_taxonomy_path(taxonomy)
    is_location? ? hash_for_nest_location_path(taxonomy) : hash_for_nest_organization_path(taxonomy)
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

  def import_mismatches_taxonomy_path(taxonomy)
    is_location? ? import_mismatches_location_path(taxonomy) : import_mismatches_organization_path(taxonomy)
  end

  def hash_for_mismatches_taxonomies_path
    is_location? ? hash_for_mismatches_locations_path : hash_for_mismatches_organizations_path
  end

  def hash_for_import_mismatches_taxnomies_path
    is_location? ? hash_for_import_mismatches_locations_path : hash_for_import_mismatches_organizations_path
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

  def organization_selects(f, selected_ids, options = {}, options_html = {})
    taxonomy_selects(f, selected_ids, Organization, 'Organizations', options, options_html)
  end

  def location_selects(f, selected_ids, options = {}, options_html = {})
    taxonomy_selects(f, selected_ids, Location, 'Locations', options, options_html)
  end

  def taxonomy_selects(f, selected_ids, taxonomy, label, options = {}, options_html = {})
    options[:disabled] = Array.wrap(options[:disabled])
    options[:label] ||= _(label)
    multiple_selects f, label.downcase.singularize + '_ids', taxonomy.authorized("assign_#{label.downcase}", taxonomy), selected_ids, options, options_html
  end

  def all_checkbox(f, resource)
    return ''.html_safe unless User.current.admin? || User.current.filters.joins(:permissions).where({:'permissions.name' => "view_#{resource}",
                                                       :search => nil,
                                                       :taxonomy_search => nil}).present?
    checkbox_f(f, :ignore_types,
      {:label => translated_label(resource, :all),
       :multiple => true,
       :onchange => 'ignore_checked(this)'},
      resource.to_s.classify)
  end

  def show_resource_if_allowed(f, taxonomy, resource_options)
    if resource_options.is_a? Hash
      resource = resource_options[:resource]
      association = resource_options[:association]
    else
      resource = resource_options
      association = resource.to_s.classify.constantize
    end
    return unless User.current.allowed_to?("view_#{resource}".to_sym)
    ids = "#{association.where(nil).klass.to_s.underscore.singularize}_ids".to_sym

    content_tag(:div, :id => resource, :class => "tab-pane") do
      all_checkbox(f, resource) +
      multiple_selects(f, association.where(nil).klass.to_s.underscore.pluralize.to_sym, association, taxonomy.selected_or_inherited_ids[ids],
        {:disabled => taxonomy.used_and_selected_or_inherited_ids[ids],
         :label => translated_label(resource, :select)},
        {'data-mismatches' => taxonomy.need_to_be_selected_ids[ids].to_json,
         'data-inheriteds' => taxonomy.inherited_ids[ids].to_json,
         'data-useds' => taxonomy.used_ids[ids].to_json })
    end
  end

  def translated_label(resource, verb)
    labels = { :users => { :all => _("All users"), :select => _("Select users") },
               :smart_proxies => { :all => _("All smart proxies"), :select => _("Select smart proxies") },
               :subnets => { :all => _("All subnets"), :select => _("Select subnets") },
               :compute_resources => { :all => _("All compute resources"), :select => _("Select compute resources") },
               :media => { :all => _("All media"), :select => _("Select media") },
               :provisioning_templates => { :all => _("All provisioning templates"), :select => _("Select provisioning templates") },
               :ptables => { :all => _("All partition tables"), :select => _("Select partition tables") },
               :domains => { :all => _("All domains"), :select => _("Select domains") },
               :realms => { :all => _("All realms"), :select => _("Select realms") },
               :environments => { :all => _("All environments"), :select => _("Select environments") },
               :hostgroups => { :all => _("All host groups"), :select => _("Select host groups") },
    }
    labels[resource][verb]
  end
end
