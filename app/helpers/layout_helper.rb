module LayoutHelper
  def title(page_title, page_header = nil)
    content_for(:title, page_title.to_s)
    @page_header       = page_header || @content_for_title || page_title.to_s
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
    content_for(:head) { stylesheet_link_tag(*args) }
  end

  def javascript(*args)
    content_for(:head) { javascript_include_tag(*args) }
  end

  def text_f(f, attr, options = {})
    field(f, attr, options) do
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
      f.text_area attr, options
    end
  end

  def password_f(f, attr, options = {})
    field(f, attr, options) do
      f.password_field attr, options
    end
  end

  def checkbox_f(f, attr, options = {}, checked_value="1", unchecked_value="0")
    text = options.delete(:help_text)
    inline = options.delete(:help_inline)
    field(f, attr, options) do
      label_tag('', :class=>'checkbox') do
        help_inline = inline.blank? ? '' : content_tag(:span, inline, :class => "help-inline")
        f.check_box(attr, options, checked_value, unchecked_value) + " #{text} " + help_inline.html_safe
      end
    end
  end


  def multiple_checkboxes(f, attr, klass, associations, options = {}, html_options={})
    if associations.count > 5
      associated_obj = klass.send(ActiveModel::Naming.plural(associations.first))
      selected_ids = associated_obj.select("#{associations.first.class.table_name}.id").map(&:id)
      multiple_selects(f, attr, associations, selected_ids, options, html_options)
    else
      field(f, attr, options) do
        authorized_edit_habtm klass, associations, options[:prefix]
      end
    end
  end

  # add hidden field for options[:disabled]
  def multiple_selects(f, attr, associations, selected_ids, options={}, html_options={})
    field(f, attr,options) do
      attr_ids = (attr.to_s.singularize+"_ids").to_sym
      hidden_fields = f.hidden_field(attr_ids, :multiple => true, :value => '', :id=>'')
      options[:disabled] ||=[]
      options[:disabled].each do |disabled_value|
        hidden_fields += f.hidden_field(attr_ids, :multiple => true, :value => disabled_value, :id=>'' )
      end
      hidden_fields + f.collection_select(attr_ids, associations.all.sort_by { |a| a.to_s },
                                          :id, :to_s ,options.merge(:selected => selected_ids),
                                          html_options.merge(:multiple => true))
    end
  end

  def radio_button_f(f, attr, options = {})
    text = options.delete(:text)
    value = options.delete(:value)
    label_tag('', :class=>"radio inline") do
      f.radio_button(attr, value, options) + " #{text} "
    end
  end

  def select_f(f, attr, array, id, method, select_options = {}, html_options = {})
    field(f, attr, html_options) do
      f.collection_select attr, array, id, method, select_options, html_options
    end
  end

  def selectable_f(f, attr, array, select_options = {}, html_options = {})
    field(f, attr, html_options) do
      f.select attr, array, select_options, html_options
    end
  end

  def file_field_f(f, attr, options = {})
    field(f, attr, options) do
      f.file_field attr, options
    end
  end

  def field(f, attr, options = {})
    fluid = options[:fluid]
    error = f.object.errors[attr] if f && f.object.respond_to?(:errors)
    inline = options.delete(:help_inline)
    inline = error.to_sentence.html_safe unless error.empty?
    help_inline = inline.blank? ? '' : content_tag(:span, inline, :class => "help-inline")
    help_block  = content_tag(:span, options.delete(:help_block), :class => "help-block")
    content_tag :div, :class => "control-group #{fluid ? "row-fluid" : ""} #{error.empty? ? "" : 'error'}" do
      label = options.delete(:label) || s_(f.object.class.gettext_translation_for_attribute_name attr)
      label_tag(attr, label, :class=>"control-label").html_safe +
        content_tag(:div, :class => "controls") do
          yield.html_safe + help_inline.html_safe + help_block.html_safe
        end.html_safe
    end
  end

  def submit_or_cancel f, overwrite = false, args = { }
    args[:cancel_path] ||= eval "#{controller_name}_path"
    content_tag(:div, :class => "form-actions") do
      text    = overwrite ? _("Overwrite") : _("Submit")
      options = overwrite ? {:class => "btn btn-danger"} : {:class => "btn btn-primary"}
      link_to(_("Cancel"), args[:cancel_path], :class => "btn") + " " +
      f.submit(text, options)
    end
  end

  def base_errors_for obj
    unless obj.errors[:base].blank?
      content_tag(:div, :class => "alert alert-message alert-block alert-error base in fade") do
        ("<a class='close' href='#' data-dismiss='alert'>&times;</a><h4>" + _("Unable to save") + "</h4> " + obj.errors[:base].map {|e| "<li>#{e}</li>"}.join).html_safe
      end
    end
  end

  def popover title, msg, options = {}
    link_to icon_text("info-sign"), {}, {:remote => true, :rel => "popover", :data => {"content" => msg, "original-title" => title} }.merge(options)
  end

   def will_paginate(collection = nil, options = {})
    options.merge!(:class=>"span7  pagination")
    options[:renderer] ||= "WillPaginate::ActionView::BootstrapLinkRenderer"
    options[:inner_window] ||= 2
    options[:outer_window] ||= 0
    super collection, options
  end

  def page_entries_info(collection, options = {})
    html = super(collection, options)
    html += options[:more].html_safe if options[:more]
    content_tag(
      :div,content_tag(
          :ul, content_tag(
              :li, link_to(html, "#")
          ), :style=>"float: left;"
      ), :class => "span4 pagination")
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
    content_tag :i, :class=>"icon-#{i}" do
      yield
    end
  end

  def icon_text(i, text="", opts = {})
    (content_tag(:i,"", :class=>"icon-#{i} #{opts[:class]}") + " " + text).html_safe
  end

  def alert opts = {}
    opts[:close] ||= true
    opts[:header] ||= _("Warning!")
    opts[:text] ||= _("Alert")
    content_tag :div, :class => "alert #{opts[:class]}" do
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
    "<a class='close' href='#' data-dismiss='alert'>&times;</a>".html_safe
  end

end
