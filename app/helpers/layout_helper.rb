module LayoutHelper
  def title(page_title, page_header = nil)
    content_for(:title, page_title.to_s)
    @page_header       = page_header || @content_for_title
  end

  def title_actions *elements
    content_for(:title_actions) { elements.join(" ").html_safe }
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
    field(f, attr, options) do
      f.check_box attr, options
    end
  end

  def multiple_checkboxes(f, attr, obj, klass, options = {})
    field(f, attr, options) do
      authorized_edit_habtm obj, klass
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
    obj = f.object
    error = obj.errors[attr] if obj.respond_to?(:errors)
    help_inline = content_tag(:span, (error.empty? ? options.delete(:help_inline) : error.to_sentence.html_safe), :class => "help-inline")
    help_block  = content_tag(:span, options.delete(:help_block), :class => "help-block")
    content_tag :div, :class => "clearfix #{error.empty? ? "" : 'error'}" do
      f.label(attr, options.delete(:label)).html_safe +
        content_tag(:div, :class => "input") do
          yield.html_safe + help_inline.html_safe + help_block.html_safe
        end.html_safe
    end
  end

  def submit_or_cancel f, overwrite = false
    "<br>".html_safe + content_tag(:p, :class => "ra") do
      text    = overwrite ? "Overwrite" : "Submit"
      options = overwrite ? {:class => "btn btn-danger"} : {:class => "btn btn-primary"}
      link_to("Cancel", eval("#{controller_name}_path"), :class => "btn") + " " +
      f.submit(text, options)
    end
  end

  def base_errors_for obj
    unless obj.errors[:base].blank?
      content_tag(:div, :class => "alert-message block-message error base in fade", "data-alert" => true) do
        "<a class='close' href='#'>×</a><h4>Unable to save</h4> ".html_safe + obj.errors[:base].map {|e| "<li>#{e}</li>"}.to_s.html_safe
      end
    end
  end

  def popover title, msg, options = {}
    link_to_function title, {:rel => "popover", "data-content" => msg, "data-original-title" => title}.merge(options)
  end

   def will_paginate(collection = nil, options = {})
    options.merge!(:class=>"span10 pagination fr")
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
      ), :class => "span6 pagination")
  end

  def icons i
    content_tag :i, :class=>"icon-#{i}" do
      yield
    end
  end

end
