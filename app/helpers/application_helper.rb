# Methods added to this helper will be available to all templates in the application
module ApplicationHelper
  include HomeHelper

  protected
  def contract model
    model.to_s
  end

  def show_habtm associations
    render :partial => 'common/show_habtm', :collection => associations, :as => :association
  end

  def edit_habtm klass, association, prefix=nil
    render :partial => 'common/edit_habtm', :locals =>{:prefix => prefix, :klass => klass, :associations => association.all.sort.delete_if{|e| e == klass}}
  end

  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(icon_text("remove",""), "remove_fields(this)", :title => _("Remove Parameter"))
  end

  def trunc text, length
    text = text.to_s
    options = text.size > length ? {:'data-original-title'=>text, :rel=>'twipsy'} : {}
    content_tag(:span, truncate(text, :length => length), options).html_safe
  end

  # Creates a link to a javascript function that creates field entries for the association on the web page
  # +name+       : String containing links's text
  # +f+          : FormBuiler object
  # +association : The field are created to allow entry into this association
  # +partial+    : String containing an optional partial into which we render
  def link_to_add_fields(name, f, association, partial = nil, options = {})
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render((partial.nil? ? association.to_s.singularize + "_fields" : partial), :f => builder)
    end
    link_to_function(name, ("add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")").html_safe, add_html_classes(options, "btn btn-success") )
  end

  def link_to_remove_puppetclass klass, host
    options = klass.name.size > 28 ? {:'data-original-title'=>klass.name, :rel=>'twipsy'} : {}
    content_tag(:span, truncate(klass.name, :length => 28), options).html_safe +
    link_to_function("","remove_puppet_class(this)", :'data-class-id'=>klass.id,
                     :'data-original-title'=>"Click to remove #{klass}", :rel=>'twipsy',
                     :'data-url' => parameters_puppetclass_path( :id => klass.id),
                     :'data-host-id' => host.id,
                     :'data-animation' => "",
                     :class=>"icon-remove-sign")
  end

  def link_to_add_puppetclass klass, host, type
    options = klass.name.size > 28 ? {:'data-original-title'=>klass.name, :rel=>'twipsy'} : {}
    content_tag(:span, truncate(klass.name, :length => 28), options).html_safe +
    link_to_function("", "add_puppet_class(this)",
                       :'data-class-id' => klass.id, 'data-type' => type,
                       :'data-url' => parameters_puppetclass_path( :id => klass.id),
                       :'data-host-id' => host.try(:id),
                       :'data-original-title' => "Click to add #{klass}", :rel => 'twipsy',
                       :'data-animation' => "",
                       :class => "icon-plus-sign")
  end

  def add_html_classes options, classes
    options = options.dup unless options.nil?
    options ||= {}
    options[:class] = options[:class].dup if options.has_key? :class
    options[:class] ||= []
    options[:class] = options[:class].split /\s+/ if options[:class].is_a? String
    classes = classes.split /\s+/ if classes.is_a? String
    options[:class] += classes
    options
  end

  def check_all_roles_links
    link_to("Check all", "#", :id => "check_all_roles", :remote => true) +
    link_to("Uncheck all", "#", :id => "uncheck_all_roles", :remote => true)
  end

  # Return true if user is authorized for controller/action, otherwise false
  # +controller+ : String or symbol for the controller
  # +action+     : String or symbol for the action
  def authorized_for(controller, action)
    User.current.allowed_to?({:controller => controller.to_s.gsub(/::/, "_").underscore, :action => action}) rescue false
  end

  # Display a link if user is authorized, otherwise a string
  # +name+    : String to be displayed
  # +options+ : Hash containing
  #             :controller  : String or Symbol representing the controller
  #             :auth_action : String or Symbol representing the action to be used for authorization checks
  # +html_options+ : Hash containing html options for the link or span
  def link_to_if_authorized(name, options = {}, html_options = {})
    auth_action = options.delete :auth_action
    enable_link = authorized_for(options[:controller] || params[:controller], auth_action || options[:action])
    if enable_link
      link_to name, options, html_options
    else
      link_to_function name, nil, html_options.merge!(:class => "#{html_options[:class]} disabled", :disabled => true)
    end
  end

  def display_delete_if_authorized(options ={}, html_options ={})
    options = {:auth_action => :destroy}.merge(options)
    html_options = {:confirm => _('Are you sure?'), :method => :delete, :class => 'delete'}.merge(html_options)
    display_link_if_authorized(_("Delete"), options, html_options)
  end
  # Display a link if user is authorized, otherwise nothing
  # +name+    : String to be displayed
  # +options+ : Hash containing
  #             :controller  : String or Symbol representing the controller
  #             :auth_action : String or Symbol representing the action to be used for authorization checks
  # +html_options+ : Hash containing html options for the link or span
  def display_link_if_authorized(name, options = {}, html_options = {})
    auth_action = options.delete :auth_action
    enable_link = html_options.has_key?(:disabled) ? !html_options[:disabled] : true
    if enable_link and authorized_for(options[:controller] || params[:controller], auth_action || options[:action])
      link_to(name, options, html_options)
    else
      ""
    end
  end

  def authorized_edit_habtm klass, association, prefix=nil
    return edit_habtm(klass, association, prefix) if authorized_for params[:controller], params[:action]
    show_habtm klass.send(association.name.pluralize.downcase)
  end

  # renders a style=display based on an attribute properties
  def display? attribute = true
    "style=#{display(attribute)}"
  end

  def display attribute
    "display:#{attribute ? 'none' : 'inline'};"
  end

  # return our current model instance type based on the current controller
  # i.e. HostsController would return "host"
  def type
    controller_name.singularize
  end

  def checked_icon condition
    image_tag("toggle_check.png") if condition
  end

  def searchable?
    return false if (SETTINGS[:login] and !User.current )
    return false unless @searchbar
    if (controller.action_name == "index") or (defined?(SEARCHABLE_ACTIONS) and (SEARCHABLE_ACTIONS.include?(controller.action_name)))
      controller.respond_to?(:auto_complete_search)
    end
  end

  def auto_complete_search(name, val, options = {})
    path = eval("#{controller_name}_path")
    options.merge!(:class => "autocomplete-input", :'data-url' => "#{path}/auto_complete_#{name}" )
    text_field_tag(name, val, options)
  end

  def help_path
    link_to _("Help"), :action => "welcome" if File.exists?("#{Rails.root}/app/views/#{controller_name}/welcome.html.erb")
  end

  def method_path method
    eval("#{method}_#{controller_name}_path")
  end

  def edit_textfield(object, property, options={})
    edit_inline(object, property, options.merge({:type => "edit_textfield"}))
  end

  def edit_textarea(object, property, options={})
    edit_inline(object, property, options.merge({:type => "edit_textarea"}))
  end

  def edit_select(object, property, options={})
    edit_inline(object, property, options.merge({:type => "edit_select"}))
  end

  def flot_pie_chart name, title, data, options = {}
    data = data.map { |k,v| {:label=>k.to_s.humanize, :data=>v} } if  data.is_a?(Hash)
    header = content_tag(:h4,(options[:show_title]) ? title : '', :class=>'ca pie-title', :'data-original-title'=>"Expand the chart", :rel=>'twipsy')
    link_to_function(header, "expand_chart(this)")+
        content_tag(:div, nil,
                    { :id    => name,
                      :class => 'statistics-pie',
                      :data  => {
                        :'title'  => title,
                        :'series' => data,
                        :'url'    => options[:search] ? "#{request.script_name}/hosts?search=#{URI.encode(options.delete(:search))}" : "#"
                      }
                    }.merge(options))
  end

  def flot_chart name, xaxis_label, yaxis_label, data, options = {}
    data = data.map { |k,v| {:label=>k.to_s.humanize, :data=>v} } if  data.is_a?(Hash)
    content_tag(:div, nil,
                { :id    => name,
                  :class => 'statistics-chart',
                  :data  => {
                      :'legend-options' => options.delete(:legend),
                      :'xaxis-label'    => xaxis_label,
                      :'yaxis-label'    => yaxis_label,
                      :'series'         => data
                  }
                }.merge(options))
  end

  def flot_bar_chart name, xaxis_label, yaxis_label, data, options = {}
    i=0
    ticks = nil
    if data.is_a?(Array)
      data = data.map do |kv|
        ticks ||=[]
        ticks << [i+=1,kv[0].to_s.humanize ]
        [i,kv[1]]
      end
    elsif  data.is_a?(Hash)
      data = data.map do |k,v|
        ticks ||=[]
        ticks << [i+=1,k.to_s.humanize ]
        [i,v]
      end
    end

    content_tag(:div, nil,
                { :id   => name,
                  :data => {
                    :'xaxis-label' => xaxis_label,
                    :'yaxis-label' => yaxis_label,
                    :'chart'   => data,
                    :'ticks'   => ticks
                  }
                }.merge(options))
  end

  def action_buttons(*args)
    content_tag(:div, :class => "btn-toolbar btn-toolbar-condensed") do
      toolbar_action_buttons args
    end
  end

  def toolbar_action_buttons(*args)
    # the no-buttons code is needed for users with less permissions
    return unless args
    args = args.flatten.map{|arg| arg unless arg.blank?}.compact
    return if args.length == 0

    #single button
    return content_tag(:span, args[0].html_safe, :class=>'btn btn-small') if args.length == 1

    #multiple buttons
    primary =  args.delete_at(0).html_safe
    primary = content_tag(:span, primary, :class=>'btn btn-small') if primary !~ /btn/

    content_tag(:div,:class => "btn-group") do
      primary + link_to(content_tag(:i, '', :class=>'caret'),'#', :class=>"btn #{'btn-small' if primary =~ /small/} dropdown-toggle", :'data-toggle'=>'dropdown') +
      content_tag(:ul,:class=>"dropdown-menu") do
        args.map{|option| content_tag(:li,option)}.join(" ").html_safe
      end
    end
  end

  def gravatar_image_tag(email, html_options = {})
    default_image = "assets/user.jpg"
    html_options.merge!(:onerror=>"this.src='#{default_image}'")
    image_tag(gravatar_url(email, default_image), html_options)
  end

  def gravatar_url(email, default_image)
    return default_image if email.blank?
    "#{request.protocol}//secure.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}?d=mm&s=30"
  end

  private
  def edit_inline(object, property, options={})
    name       = "#{type}[#{property}]"
    helper     = options[:helper]
    value      = helper.nil? ? object.send(property) : self.send(helper, object)
    klass      = options[:type]
    update_url = options[:update_url] || url_for(object)

    opts = { :title => _("Click to edit"), "data-url" => update_url, :class => "editable #{klass}",
      :name => name, "data-field" => property, :value => value, :select_values => options[:select_values]}

    content_tag_for :span, object, opts do
      h(value)
    end

  end

end
