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

  def textarea_f(f, attr, options = {})
    field(f, attr, options) do
      f.text_area attr, options
    end
  end

  def password_f(f, attr, options = {})
    field(f, attr, options) do
      f.password_field attr, options
    end
  end

  def checkbox_f(f, attr, options = {})
    text = options.delete(:help_inline)
    field(f, attr, options) do
      label_tag('', :class=>'checkbox') do
      f.check_box(attr, options) + " #{text} "
      end
    end
  end

  def multiple_checkboxes(f, attr, obj, klass, options = {})
    field(f, attr, options) do
      authorized_edit_habtm obj, klass, options[:prefix]
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
    error = f.object.errors[attr] if f.object.respond_to?(:errors)
    inline = error.empty? ? options.delete(:help_inline) : error.to_sentence.html_safe
    help_inline = inline.blank? ? '' : content_tag(:span, inline, :class => "help-inline")
    help_block  = content_tag(:span, options.delete(:help_block), :class => "help-block")
    content_tag :div, :class => "control-group #{error.empty? ? "" : 'error'}" do
      label_tag(attr, options.delete(:label), :class=>"control-label").html_safe +
        content_tag(:div, :class => "controls") do
          yield.html_safe + help_inline.html_safe + help_block.html_safe
        end.html_safe
    end
  end

  def submit_or_cancel f, overwrite = false, args = { }
    args[:cancel_path] ||= eval "#{controller_name}_path"
    content_tag(:div, :class => "form-actions") do
      text    = overwrite ? "Overwrite" : "Submit"
      options = overwrite ? {:class => "btn btn-danger"} : {:class => "btn btn-primary"}
      link_to("Cancel", args[:cancel_path], :class => "btn") + " " +
      f.submit(text, options)
    end
  end

  def base_errors_for obj
    unless obj.errors[:base].blank?
      content_tag(:div, :class => "alert alert-message alert-block alert-error base in fade") do
        "<a class='close' href='#' data-dismiss='alert'>&times;</a><h4>Unable to save</h4> ".html_safe + obj.errors[:base].map {|e| "<li>#{e}</li>"}.to_s.html_safe
      end
    end
  end

  def popover title, msg, options = {}
    link_to_function title, {:class => "label label-info", :rel => "popover", "data-content" => msg, "data-original-title" => title}.merge(options)
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

end
