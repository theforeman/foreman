module LayoutHelper
  def title(page_title, page_header = nil)
    content_for(:title, page_title.to_s)
    @page_header       ||= page_header || @content_for_title || page_title.to_s
  end

  def title_actions *elements
    content_for(:title_actions) { elements.join(" ").html_safe }
  end

  def button_group *elements
    content_tag(:div,:class=>"btn-group") { elements.join(" ").html_safe }
  end

  def search_bar *elements
    content_for(:search_bar) { elements.join(" ").html_safe }
  end

  def stylesheet(*args)
    content_for(:stylesheets) { stylesheet_link_tag(*args) }
  end

  def javascript(*args)
    content_for(:javascripts) { javascript_include_tag(*args) }
  end

  def addClass(options={}, new_class='')
    options[:class] = "#{new_class} #{options[:class]}"
  end

  def text_f(f, attr, options = {})
    field(f, attr, options) do
      addClass options, "form-control"
      options[:focus_on_load] ||= attr.to_s == 'name'
      f.text_field attr, options
    end
  end

  def line_count (f, attr)
    rows = f.object.try(attr).to_s.lines.count rescue 1
    rows == 0 ? 1 : rows
  end

  def textarea_f(f, attr, options = {})
    field(f, attr, options) do
      options[:rows] = line_count(f, attr) if options[:rows] == :auto
      addClass options, "form-control"
      f.text_area attr, options
    end
  end

  def password_f(f, attr, options = {})
    field(f, attr, options) do
      options[:autocomplete] ||= "off"
      options[:placeholder] ||= password_placeholder(f.object)
      addClass options, "form-control"
      f.password_field attr, options
    end
  end

  def checkbox_f(f, attr, options = {}, checked_value="1", unchecked_value="0")
    text = options.delete(:help_text)
    inline = options.delete(:help_inline)
    field(f, attr, options) do
      help_inline = inline.blank? ? '' : content_tag(:span, inline, :class => "help-block")
      f.check_box(attr, options, checked_value, unchecked_value) + " #{text} " + help_inline.html_safe
    end
  end


  def multiple_checkboxes(f, attr, klass, associations, options = {}, html_options={})
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
  def multiple_selects(f, attr, associations, selected_ids, options={}, html_options={})
    options.merge!(:size => "col-md-10")
    field(f, attr, options) do
      attr_ids = (attr.to_s.singularize+"_ids").to_sym
      hidden_fields = ''
      html_options["data-useds"] ||= "[]"
      JSON.parse(html_options["data-useds"]).each do |disabled_value|
        hidden_fields += f.hidden_field(attr_ids, :multiple => true, :value => disabled_value, :id=>'' )
      end
      hidden_fields + f.collection_select(attr_ids, associations.all.sort_by { |a| a.to_s },
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
    html_options.merge!(:size => 'col-md-10') if html_options[:multiple]
    field(f, attr, html_options) do
      addClass html_options, "form-control"
      f.collection_select attr, array, id, method, select_options, html_options
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
      path = options.delete(:path) || send("#{f.object.class.pluralize.underscore}_path")
      auto_complete_search(attr,
                           f.object.send(attr).try(:squeeze, " "),
                           options.merge(
                               :placeholder => _("Filter") + ' ...',
                               :path        => path,
                               :name       => "#{f.object_name}[#{attr}]"
                           )
      ).html_safe
    end
  end

  def field(f, attr, options = {})
    error = f.object.errors[attr] if f && f.object.respond_to?(:errors)
    help_inline = help_inline(options.delete(:help_inline), error)

    help_block  = content_tag(:span, options.delete(:help_block), :class => "help-block")
    size_class = options.delete(:size) || "col-md-4"
    content_tag(:div, :class=> "clearfix") do
      content_tag :div, :class => "form-group #{error.empty? ? "" : 'has-error'}",
                  :id          => options.delete(:control_group_id) do

        required_mark = ' *' if is_required?(f, attr) || options[:required]
        label   = options[:label] == :none ? '' : options.delete(:label)
        label ||= ((clazz = f.object.class).respond_to?(:gettext_translation_for_attribute_name) &&
            s_(clazz.gettext_translation_for_attribute_name attr)) if f
        label   = label.present? ? label_tag(attr, "#{label}#{required_mark}".html_safe , :class => "col-md-2 control-label") : ''

        label.html_safe +
           content_tag(:div, :class => size_class) do
             yield.html_safe + help_block.html_safe
           end.html_safe + help_inline.html_safe
      end.html_safe
    end
  end

  def is_required?(f, attr)
    return false unless f && f.object.class.respond_to?(:validators_on)
    f.object.class.validators_on(attr).map(&:class).include? ActiveModel::Validations::PresenceValidator
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

  def form_to_submit_id f
    object = f.object.respond_to?(:to_model) ? f.object.to_model : f.object
    key = object ? (object.persisted? ? :update : :create) : :submit
    model = if object.class.respond_to?(:humanize_class_name)
              object.class.humanize_class_name.downcase
            elsif object.class.respond_to?(:model_name)
              object.class.model_name.human.downcase
            else
              f.object_name.to_s
            end.gsub(/\W+/, '_')
    "aid_#{key}_#{model}"
  end

  def submit_or_cancel f, overwrite = false, args = { }
    args[:cancel_path] ||= send("#{controller_name}_path")
    content_tag(:div, :class => "clearfix") do
      content_tag(:div, :class => "form-actions") do
        text    = overwrite ? _("Overwrite") : _("Submit")
        options = overwrite ? {:class => "btn btn-danger"} : {:class => "btn btn-primary"}
        options.merge! :'data-id' => form_to_submit_id(f) unless options.has_key?(:'data-id')
        link_to(_("Cancel"), args[:cancel_path], :class => "btn btn-default") + " " +
            f.submit(text, options)
      end
    end
  end

  def base_errors_for obj
    unless obj.errors[:base].blank?
      alert :header => _("Unable to save"),
            :class  => 'alert-danger base in fade',
            :text   => obj.errors[:base].map { |e| '<li>'.html_safe + e + '</li>'.html_safe }.join.html_safe
    end
  end

  def popover title, msg, options = {}
    link_to icon_text("info-sign", title), {}, { :remote => true, :rel => "popover", :data => {"content" => msg, "original-title" => title} }.merge(options)
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
    content_tag(:div, :class=>"col-md-5") do
      content_tag(:ul, :class => 'pagination') do
        content_tag(:li, link_to(html, "#"), :class=>"pull-left")
      end
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

  def icons i
    content_tag :i, :class=>"glyphicon glyphicon-#{i}" do
      yield
    end
  end

  def icon_text(i, text="", opts = {})
    (content_tag(:i,"", :class=>"glyphicon glyphicon-#{i} #{opts[:class]}") + " " + text).html_safe
  end

  def alert opts = {}
    opts[:close]  = true if opts[:close].nil?
    opts[:header] ||= _("Warning!")
    opts[:text]   ||= _("Alert")
    html_class    = "alert #{opts[:class]} "
    html_class    += 'alert-dismissable' if opts[:close]
    content_tag :div, :class => html_class do
      result = "".html_safe
      result += alert_close if opts[:close]
      result += alert_header(opts[:header])
      result += opts[:text].html_safe
      result
    end
  end

  def alert_header text
    "<h4 class='alert-heading'>#{text}</h4>".html_safe
  end

  def alert_close
    '<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>'.html_safe
  end

  def trunc(text, length = 32)
    text    = text.to_s
    options = text.size > length ? { :'data-original-title' => text, :rel => 'twipsy' } : {}
    content_tag(:span, truncate(text, :length => length), options).html_safe
  end

end
