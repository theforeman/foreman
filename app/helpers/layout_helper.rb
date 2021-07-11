module LayoutHelper
  def mount_react_app
    react_component('ReactApp', {
                      layout: layout_data,
                      metadata: app_metadata,
                      toasts: toast_notifications_data,
                      routes: routes,
                    })
  end

  def fetch_menus
    UserMenu.new.menus.flatten
  end

  def available_organizations
    Organization.my_organizations.map do |organization|
      {id: organization.id, title: organization.title, href: main_app.select_organization_path(organization)}
    end
  end

  def available_locations
    Location.my_locations.map do |location|
      {id: location.id, title: location.title, href: main_app.select_location_path(location)}
    end
  end

  def current_organization
    Organization&.current&.title
  end

  def current_location
    Location&.current&.title
  end

  def fetch_organizations
    { current_org: current_organization, available_organizations: available_organizations }
  end

  def fetch_locations
    { current_location: current_location, available_locations: available_locations }
  end

  def fetch_user
    { current_user: User.current, user_dropdown: Menu::Manager.to_hash(:side_menu), impersonated_by: User.unscoped.find_by_id(session[:impersonated_by]) }
  end

  def routes
    []
  end

  def layout_data
    { menu: fetch_menus,
      logo: image_path("header_logo.svg", :class => "header-logo"),
      notification_url: main_app.notification_recipients_path,
      stop_impersonation_url: main_app.stop_impersonation_users_path,
      user: fetch_user, brand: 'foreman',
      root: main_app.root_path,
      locations: fetch_locations, orgs: fetch_organizations,
      instance_title: Setting[:instance_title]
    }
  end

  def title(page_title, page_header = nil)
    content_for(:title, page_title.to_s)
    @page_header ||= page_header || page_title.to_s
  end

  def title_actions(*elements)
    content_for(:title_actions) { elements.join(" ").html_safe }
  end

  def button_group(*elements)
    content_tag(:div, :class => "btn-group") { elements.join(" ").html_safe }
  end

  def search_bar(*elements)
    content_for(:search_bar) { elements.join(" ").html_safe }
  end

  def mount_breadcrumbs(options = {}, &block)
    options = BreadcrumbsOptions.new(@page_header, controller, action_name, block_given? ? yield : options)

    if !@welcome && response.ok?
      react_component("BreadcrumbBar", options.bar_props)
    elsif @page_header.present?
      content_tag(:div, class: 'row form-group') do
        content_tag(:h1, h(@page_header), class: 'col-md-8')
      end
    end
  end

  def breadcrumbs(options = {}, &block)
    content_for(:breadcrumbs) do
      mount_breadcrumbs(options, &block)
    end
  end

  def stylesheet(*args)
    content_for(:stylesheets) { stylesheet_link_tag(*args) }
  end

  def javascript(*args)
    content_for(:javascripts) { javascript_include_tag(*args) }
  end

  # The target should have class="collapse [out|in]" out means collapsed on load and in means expanded.
  # Target must also have a unique id.
  def collapsing_header(title, target, collapsed = '')
    content_tag(:h2, :class => "expander #{collapsed}", :data => {:toggle => 'collapse', :target => target}) do
      content_tag(:span, '', :class => 'caret') + title
    end
  end

  def base_errors_for(obj)
    if obj.errors[:base].present?
      alert :header => _("Unable to save"),
            :class  => 'alert-danger base in fade',
            :text   => obj.errors[:base].map { |e| '<li>'.html_safe + e + '</li>'.html_safe }.join.html_safe
    end
  end

  def popover(title, msg, options = {})
    options[:icon] ||= 'info'
    options[:kind] ||= 'pficon'
    content_tag(:a, icon_text(options[:icon], title, :kind => options[:kind]), { :rel => "popover",
                                                                           :data => { :content => msg,
                                                                                      :"original-title" => title,
                                                                                      :trigger => "focus",
                                                                                      :container => 'body',
                                                                                      :html => true },
                                                                           :role => 'button',
                                                                           :tabindex => '-1' }.deep_merge(options))
  end

  def icon_text(i, text = "", opts = {})
    opts[:kind] ||= "glyphicon"
    (content_tag(:span, "", :class => "#{opts[:kind] + ' ' + opts[:kind]}-#{i} #{opts[:class]}", :title => opts[:title]) + " " + text).html_safe
  end

  def alert(opts = {})
    opts[:close] = true if opts[:close].nil?
    opts[:header] ||= _("Warning!")
    opts[:text]   ||= _("Alert")
    html_class = "alert #{opts[:class]} "
    html_class += 'alert-dismissable' if opts[:close]
    content_tag :div, :class => html_class, :id => opts[:id] do
      result = "".html_safe
      result += alert_close if opts[:close]
      result += alert_header(opts[:header], opts[:class])
      result += content_tag(:span, opts[:text], :class => 'text')
      result += alert_actions(opts[:actions]) if opts[:actions].present?
      result
    end
  end

  def alert_header(text, html_class = nil)
    case html_class
      when /alert-success/
        icon = icon_text("ok", "", :kind => "pficon")
        text ||= _("Notice")
      when /alert-warning/
        icon = icon_text("warning-triangle-o", "", :kind => "pficon")
        text ||= _("Warning")
      when /alert-info/
        icon = icon_text("info", "", :kind => "pficon")
        text ||= _("Notice")
      when /alert-danger/
        icon = icon_text("error-circle-o", "", :kind => "pficon")
        text ||= _("Error")
    end
    header = icon.to_s
    header += content_tag(:strong, text + ' ') if text.present?
    header.html_safe
  end

  def alert_close(data_dismiss = 'alert')
    "<button type='button' class='close' data-dismiss='#{data_dismiss}' aria-hidden='true'>&times;</button>".html_safe
  end

  def trunc_with_tooltip(text, length = 32, tooltip_text = "", shorten = true)
    text = text.to_s.empty? ? tooltip_text.to_s : text.to_s
    tooltip_text = tooltip_text.to_s.empty? ? text : tooltip_text.to_s
    options = (shorten && (text.size < length)) ? {} : { :'data-original-title' => tooltip_text, :rel => 'twipsy' }
    if shorten
      content_tag(:span, truncate(text, :length => length), options).html_safe
    else
      content_tag(:span, text, options).html_safe
    end
  end

  def alert_actions(actions)
    content_tag :div, :class => 'alert-actions' do
      '<hr>'.html_safe + actions
    end
  end

  def modal_close(text = _('Close'))
    button_tag(text, :class => 'btn btn-default', :data => { :dismiss => 'modal' })
  end

  def last_days(days)
    content_tag(:h6, n_("last %s day", "last %s days", days) % days, :class => 'ca')
  end

  def fullscreen_button(element = "$(this).prev()")
    button_tag(:type => 'button', :class => 'btn btn-default btn-md btn-fullscreen', :onclick => "set_fullscreen(#{element})", :title => _("Full screen")) do
      icon_text('expand', '', :kind => 'fa')
    end
  end

  def fullscreen_input(element = "$(this).closest('.input-group').find('input,textarea')")
    content_tag(:span, fullscreen_button(element), :class => 'input-group-btn')
  end

  def new_child_fields_template(form_builder, association, options = { })
    unless options[:object].present?
      association_object = form_builder.object.class.reflect_on_association(association)
      options[:object] = association_object.klass.new(association_object.foreign_key => form_builder.object.id)
    end
    options[:partial]            ||= association.to_s.singularize
    options[:form_builder_local] ||= :f
    options[:form_builder_attrs] ||= {}

    content_tag(:div, :class => "#{association}_fields_template form_template", :style => "display: none;") do
      form_builder.fields_for(association, options[:object], :child_index => "new_#{association}") do |f|
        render(:partial => options[:partial], :layout => options[:layout],
               :locals => { options[:form_builder_local] => f }.merge(options[:form_builder_attrs]))
      end
    end
  end

  def render_if_partial_exists(path, f)
    render path, :f => f if lookup_context.exists?(path, [], true)
  end

  def per_page(collection)
    per_page = params[:per_page] ? params[:per_page].to_i : Setting[:entries_per_page]
    [per_page, collection.total_entries].min
  end

  private

  def table_css_classes(classes = '')
    "table table-bordered table-striped table-hover " + classes
  end
end
