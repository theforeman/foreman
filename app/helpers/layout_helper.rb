module LayoutHelper
  def title(page_title, page_header = nil)
    content_for(:title, page_title.to_s)
    @page_header       ||= page_header || @content_for_title || page_title.to_s
  end

  def title_actions(*elements)
    content_for(:title_actions) { elements.join(" ").html_safe }
  end

  def button_group(*elements)
    content_tag(:div,:class=>"btn-group") { elements.join(" ").html_safe }
  end

  def search_bar(*elements)
    content_for(:search_bar) { elements.join(" ").html_safe }
  end

  def stylesheet(*args)
    content_for(:stylesheets) { stylesheet_link_tag(*args.push("data-turbolinks-track" => true)) }
  end

  def javascript(*args)
    content_for(:javascripts) { javascript_include_tag(*args.push("data-turbolinks-track" => true)) }
  end

  def addClass(options = {}, new_class = '')
    options[:class] = "#{new_class} #{options[:class]}"
  end

  def text_f(f, attr, options = {})
    field(f, attr, options) do
      addClass options, "form-control"
      options[:focus_on_load] ||= attr.to_s == 'name'
      f.text_field attr, options
    end
  end

  def line_count(f, attr)
    rows = f.object.try(attr).to_s.lines.count rescue 1
    rows == 0 ? 1 : rows
  end

  def textarea_f(f, attr, options = {})
    field(f, attr, options) do
      options[:rows] = line_count(f, attr) if options[:rows] == :auto
      addClass options, "form-control"
      f.text_area(attr, options)
    end
  end

  def button_input_group(content, options = {}, glyph = nil)
    options[:type] ||= 'button'
    options[:herf] ||= '#'
    options[:class] ||= 'btn btn-default'
    content_tag :span, class: 'input-group-btn' do
      content_tag :button, content, options  do
        content_tag :span,content, :class => glyph
      end
    end
  end

  def password_f(f, attr, options = {})
    unset_button = options.delete(:unset)
    password_field_tag(:fakepassword, nil, :style => 'display: none') +
    field(f, attr, options) do
      options[:autocomplete]   ||= 'off'
      options[:placeholder]    ||= password_placeholder(f.object, attr)
      options[:disabled] = true if unset_button
      addClass options, 'form-control'
      pass = f.password_field(attr, options) +
      '<span class="glyphicon glyphicon-warning-sign input-addon"
             title="'.html_safe + _('Caps lock ON') +
             '" style="display:none"></span>'.html_safe
      if unset_button
        button = button_input_group '', {:id => 'disable-pass-btn', :onclick => "toggle_input_group(this)", :title => _("Change the password")}, 'glyphicon glyphicon-pencil'
        input_group pass, button
      else
        pass
      end
    end
  end

  def checkbox_f(f, attr, options = {}, checked_value = "1", unchecked_value = "0")
    text = options.delete(:help_text)
    inline = options.delete(:help_inline)
    field(f, attr, options) do
      help_inline = inline.blank? ? '' : content_tag(:span, inline, :class => "help-inline")
      f.check_box(attr, options, checked_value, unchecked_value) + " #{text} " + help_inline.html_safe
    end
  end

  def multiple_checkboxes(f, attr, klass, associations, options = {}, html_options = {})
    if associations.count > 5
      associated_obj = klass.send(ActiveModel::Naming.plural(associations.first))
      selected_ids = associated_obj.select("#{associations.first.class.table_name}.id").map(&:id)
      multiple_selects(f, attr, associations, selected_ids, options, html_options)
    else
      field(f, attr, options) do
        authorized_edit_habtm klass, associations, options[:prefix], html_options
      end
    end
  end

  # add hidden field for options[:disabled]
  def multiple_selects(f, attr, associations, selected_ids, options = {}, html_options = {})
    options.merge!(:size => "col-md-10")
    authorized = AssociationAuthorizer.authorized_associations(associations).all

    # select2.js breaks the multiselects disabled items location
    # http://projects.theforeman.org/issues/12028
    html_options["class"] ||= ""
    html_options["class"] += " without_select2"
    html_options["class"].strip!

    unauthorized = selected_ids.blank? ? [] : selected_ids - authorized.map(&:id)
    field(f, attr, options) do
      attr_ids = (attr.to_s.singularize+"_ids").to_sym
      hidden_fields = ''
      html_options["data-useds"] ||= "[]"
      JSON.parse(html_options["data-useds"]).each do |disabled_value|
        hidden_fields += f.hidden_field(attr_ids, :multiple => true, :value => disabled_value, :id=>'' )
      end
      unauthorized.each do |unauthorized_value|
        hidden_fields += f.hidden_field(attr_ids, :multiple => true, :value => unauthorized_value, :id=>'' )
      end
      hidden_fields + f.collection_select(attr_ids, authorized.sort_by { |a| a.to_s },
                                          :id, :to_label, options.merge(:selected => selected_ids),
                                          html_options.merge(:multiple => true))
    end
  end

  def radio_button_f(f, attr, options = {})
    text = options.delete(:text)
    value = options.delete(:value)
    label_tag('', :class=>"radio-inline") do
      f.radio_button(attr, value, options) + " #{text} "
    end
  end

  def select_f(f, attr, array, id, method, select_options = {}, html_options = {})
    array = array.to_a.dup
    disable_button = select_options.delete(:disable_button)
    include_blank = select_options.delete(:include_blank)
    disable_button_enabled = select_options.delete(:disable_button_enabled)
    user_set = !!select_options.delete(:user_set)

    if include_blank
      blank_value = include_blank.is_a?(TrueClass) ? nil : include_blank
      blank_option = OpenStruct.new({id => '', method => blank_value })
      # if the method is to_s, OpenStruct will respond with its own version.
      # in this case, I need to undefine its own alias to to_s, and use the attribute
      # that was defined in the struct.
      blank_option.instance_eval('undef to_s') if method.to_s == 'to_s' || id.to_s == 'to_s'
      array.insert(0, blank_option)
    end

    select_options[:disabled] = '' if select_options[:disabled] == include_blank
    html_options.merge!(:disabled => true) if disable_button_enabled

    html_options.merge!(:size => 'col-md-10') if html_options[:multiple]
    field(f, attr, html_options) do
      addClass html_options, "form-control"

      collection_select = f.collection_select(attr, array, id, method, select_options, html_options)

      if disable_button
        button_part =
          content_tag :span, class: 'input-group-btn' do
            content_tag(:button, disable_button, :type => 'button', :href => '#',
                                       :name => 'is_overridden_btn',
                                       :onclick => "disableButtonToggle(this)",
                                       :class => 'btn btn-default btn-can-disable' + (disable_button_enabled ? ' active' : ''),
                                       :data => { :toggle => 'button', :explicit => user_set })
          end

        input_group collection_select, button_part
      else
        collection_select
      end
    end
  end

  def input_group(*controls)
    content_tag :div, class: 'input-group' do
      controls.map { |control_html| concat(control_html) }
    end
  end

  def input_group_btn(*controls)
    content_tag :span, class: 'input-group-btn' do
      controls.join(' ').html_safe
    end
  end

  def time_zone_select_f(f, attr, default_timezone, select_options = {}, html_options = {})
    field(f, attr, html_options) do
      addClass html_options, "form-control"
      f.time_zone_select(attr, [default_timezone], select_options, html_options)
    end
  end

  def selectable_f(f, attr, array, select_options = {}, html_options = {})
    html_options.merge!(:size => 'col-md-10') if html_options[:multiple]
    field(f, attr, html_options) do
      addClass html_options, "form-control"
      f.select attr, array, select_options, html_options
    end
  end

  def file_field_f(f, attr, options = {})
    field(f, attr, options) do
      f.file_field attr, options
    end
  end

  def autocomplete_f(f, attr, options = {})
    field(f, attr, options) do
      path = options.delete(:path) || send("#{f.object.class.pluralize.underscore}_path") if options[:full_path].nil?
      auto_complete_search(attr,
                           f.object.send(attr).try(:squeeze, " "),
                           options.merge(
                               :placeholder => _("Filter") + ' ...',
                               :path        => path,
                               :name        => "#{f.object_name}[#{attr}]"
                           )
      ).html_safe
    end
  end

  def field(f, attr, options = {})
    table_field = options.delete(:table_field)
    error       = options.delete(:error) || f.object.errors[attr] if f && f.object.respond_to?(:errors)
    help_inline = help_inline(options.delete(:help_inline), error)
    size_class  = options.delete(:size) || "col-md-4"
    wrapper_class = options.delete(:wrapper_class) || "form-group"

    label = options[:no_label] ? "" : add_label(options, f, attr)

    if table_field
      add_help_to_label(size_class, label, help_inline) do
        yield
      end.html_safe
    else
      help_block = content_tag(:span, options.delete(:help_block), :class => "help-block")

      content_tag(:div, :class => "clearfix") do
        content_tag(:div, :class => "#{wrapper_class} #{error.empty? ? "" : 'has-error'}",
                    :id => options.delete(:control_group_id)) do
          input = capture do
            if options[:fullscreen]
              content_tag(:div, yield.html_safe + fullscreen_input, :class => "input-group")
            else
              yield.html_safe
            end
          end
          add_help_to_label(size_class, label, help_inline) do
            input + help_block.html_safe
          end
        end.html_safe
      end
    end
  end

  def add_help_to_label(size_class, label, help_inline)
    label.html_safe +
        content_tag(:div, :class => size_class) do
          yield
        end.html_safe + help_inline.html_safe
  end

  # The target should have class="collapse [out|in]" out means collapsed on load and in means expanded.
  # Target must also have a unique id.
  def collapsing_legend(title, target, collapsed = '')
    content_tag(:legend, :class => "expander #{collapsed}", :data => {:toggle => 'collapse', :target => target}) do
      content_tag(:span, '', :class => 'caret') + title
    end
  end

  def check_required options, f, attr
    required = options.delete(:required) # we don't want to use html5 required attr so we delete the option
    return ' *' if required.nil? ? is_required?(f, attr) : required
  end

  def add_label options, f, attr
    label_size = options.delete(:label_size) || "col-md-2"
    required_mark = check_required(options, f, attr)
    label = options[:label] == :none ? '' : options.delete(:label)
    label ||= ((clazz = f.object.class).respond_to?(:gettext_translation_for_attribute_name) &&
        s_(clazz.gettext_translation_for_attribute_name attr)) if f
    label = label.present? ? label_tag(attr, "#{label}#{required_mark}".html_safe, :class => label_size + " control-label") : ''
    label
  end

  def is_required?(f, attr)
    return false unless f && f.object.class.respond_to?(:validators_on)
    f.object.class.validators_on(attr).any? do |validator|
      options = validator.options.keys.map(&:to_s)
      validator.is_a?(ActiveModel::Validations::PresenceValidator) && !options.include?('if') && !options.include?('unless')
    end
  end

  def help_inline(inline, error)
    help_inline = error.empty? ? inline : error.to_sentence.html_safe
    case help_inline
      when blank?
        ""
      when :indicator
        content_tag(:span, image_tag('spinner.gif', :class => 'hide'), :class => "help-block help-inline")
      else
        content_tag(:span, help_inline, :class => "help-block help-inline")
    end
  end

  def form_to_submit_id(f)
    object = f.object.respond_to?(:to_model) ? f.object.to_model : f.object
    key = if object.present?
            object.persisted? ? :update : :create
          else
            :submit
          end
    model = if object.class.respond_to?(:humanize_class_name)
              object.class.humanize_class_name.downcase
            elsif object.class.respond_to?(:model_name)
              object.class.model_name.human.downcase
            else
              f.object_name.to_s
            end.gsub(/\W+/, '_')
    "aid_#{key}_#{model}"
  end

  def submit_or_cancel(f, overwrite = false, args = { })
    args[:cancel_path] ||= send("#{controller_name}_path")
    content_tag(:div, :class => "clearfix") do
      content_tag(:div, :class => "form-actions") do
        text    = overwrite ? _("Overwrite") : _("Submit")
        options = {}
        options[:class] = "btn btn-#{overwrite ? 'danger' : 'primary'} remove_form_templates"
        options.merge! :'data-id' => form_to_submit_id(f) unless options.has_key?(:'data-id')
        link_to(_("Cancel"), args[:cancel_path], :class => "btn btn-default") + " " +
            f.submit(text, options)
      end
    end
  end

  def base_errors_for(obj)
    unless obj.errors[:base].blank?
      alert :header => _("Unable to save"),
            :class  => 'alert-danger base in fade',
            :text   => obj.errors[:base].map { |e| '<li>'.html_safe + e + '</li>'.html_safe }.join.html_safe
    end
  end

  def popover(title, msg, options = {})
    options[:icon] ||= 'info-sign'
    content_tag(:a, icon_text(options[:icon], title), { :rel => "popover",
                                                        :data => { :content => msg,
                                                                   :"original-title" => title,
                                                                   :trigger => "focus",
                                                                   :container => 'body',
                                                                   :html => true },
                                                        :role => 'button',
                                                        :tabindex => '-1' }.deep_merge(options))
  end

  def will_paginate(collection = nil, options = {})
    options.merge!(:class=>"col-md-7")
    options[:renderer] ||= "WillPaginate::ActionView::BootstrapLinkRenderer"
    options[:inner_window] ||= 2
    options[:outer_window] ||= 0
    options[:previous_label] ||= _('&laquo;')
    options[:next_label] ||= _('&raquo;')
    super collection, options
  end

  def page_entries_info(collection, options = {})
    html = if collection.total_entries == 0
             _("No entries found")
           else
             if collection.total_pages < 2
               n_("Displaying <b>%{count}</b> entry", "Displaying <b>all %{count}</b> entries", collection.total_entries) % {:count => collection.total_entries}
             else
               _("Displaying entries <b>%{from} - %{to}</b> of <b>%{count}</b> in total") %
                   { :from => collection.offset + 1, :to => collection.offset + collection.length, :count => collection.total_entries }
             end
           end.html_safe
    html += options[:more].html_safe if options[:more]
    content_tag(:div, :class => "col-md-5 hidden-xs") do
      content_tag(:div, html, :class => "pull-left pull-bottom darkgray pagination")
    end
  end

  def will_paginate_with_info(collection = nil, options = {})
    content_tag(:div, :id => "pagination", :class => "row") do
      page_entries_info(collection, options) +
        will_paginate(collection, options)
    end
  end

  def form_for(record_or_name_or_array, *args, &proc)
    if args.last.is_a?(Hash)
      args.last[:html] = {:class=>"form-horizontal well"}.merge(args.last[:html]||{})
    else
      args << {:html=>{:class=>"form-horizontal well"}}
    end
    super record_or_name_or_array, *args, &proc
  end

  def icons(i)
    content_tag :i, :class=>"glyphicon glyphicon-#{i}" do
      yield
    end
  end

  def icon_text(i, text = "", opts = {})
    (content_tag(:i,"", :class=>"glyphicon glyphicon-#{i} #{opts[:class]}", :title => opts[:title]) + " " + text).html_safe
  end

  def alert(opts = {})
    opts[:close]  = true if opts[:close].nil?
    opts[:header] ||= _("Warning!")
    opts[:text]   ||= _("Alert")
    html_class    = "alert #{opts[:class]} "
    html_class    += 'alert-dismissable' if opts[:close]
    content_tag :div, :class => html_class, :id => opts[:id] do
      result = "".html_safe
      result += alert_close if opts[:close]
      result += alert_header(opts[:header])
      result += content_tag(:span, opts[:text].html_safe, :class => 'text')
      result
    end
  end

  def alert_header(text)
    "<h4 class='alert-heading'>#{text}</h4>".html_safe
  end

  def alert_close(data_dismiss = 'alert')
    "<button type='button' class='close' data-dismiss='#{data_dismiss}' aria-hidden='true'>&times;</button>".html_safe
  end

  def trunc_with_tooltip(text, length = 32, tooltip_text = "", shorten = true)
    text = text.to_s.empty? ? tooltip_text.to_s : text.to_s
    tooltip_text = tooltip_text.to_s.empty? ? text : tooltip_text.to_s
    options = shorten && (text.size < length) ? {} : { :'data-original-title' => tooltip_text, :rel => 'twipsy' }
    if shorten
      content_tag(:span, truncate(text, :length => length), options).html_safe
    else
      content_tag(:span, text, options).html_safe
    end
  end

  def modal_close(data_dismiss = 'modal', text = _('Close'))
    button_tag(text, :class => 'btn btn-default', :data => { :dismiss => data_dismiss })
  end

  def number_f(f, attr, options = {})
    field(f, attr, options) do
      addClass options, "form-control"
      f.number_field attr, options
    end
  end

  def last_days(days)
    content_tag(:h6, n_("last %s day", "last %s days", days) % days, :class => 'ca')
  end

  def fullscreen_button(element = "$(this).prev()")
    button_tag(:type => 'button', :class => 'btn btn-default btn-md btn-fullscreen', :onclick => "set_fullscreen(#{element})", :title => _("Full screen")) do
      icon_text('resize-full')
    end
  end

  def fullscreen_input(element = "$(this).closest('.input-group').find('input,textarea')")
    content_tag(:span, fullscreen_button(element), :class => 'input-group-btn')
  end

  private

  def table_css_classes(classes = '')
    "table table-bordered table-striped table-condensed " + classes
  end
end
