module LayoutHelper
  def title(page_title, page_header = nil)
    @content_for_title = page_title.to_s
    @page_header       = page_header || @content_for_title
  end

  def title_actions *elements
    content_for(:title_actions) { elements.join(" ") }
  end

  def search_bar *elements
    content_for(:search_bar) { elements.join(" ") }
  end

  def stylesheet(*args)
    content_for(:head) { stylesheet_link_tag(*args) }
  end

  def javascript(*args)
    content_for(:head) { javascript_include_tag(*args) }
  end

  def will_paginate(collection = nil, options = {})
    options[:renderer] ||= "WillPaginate::ViewHelpers::BootstrapLinkRenderer"
    super collection, options
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

  def field(f, attr, options = {})
    obj = f.object
    error = obj.errors.on(attr)
    content_tag :div, :class => "clearfix #{error.empty? ? "" : 'error'}" do
      f.label(attr, options.delete(:label)) +
        content_tag(:div, :class => "input") do
          raw = ""
          raw += content_tag(:span, (error.empty? ? options[:help_inline] : error.to_a.to_sentence), :class => "help-inline")
          raw += content_tag(:span, options[:help_block], :class => "help-block")
          yield + raw
        end
    end
  end

  def submit_or_cancel f
    "<br>" + content_tag(:p, :class => "ra") do
      link_to("Cancel", eval("#{controller_name}_path"), :class => "btn") + " " +
      f.submit("Submit", :class => "btn primary")
    end
  end

  def base_errors_for obj
    if errors = obj.errors.on(:base)
      content_tag(:div, :class => "alert-message block-message error base in fade", "data-alert" => true) do
        '<a class="close" href="#">×</a>' + "<h4>Unable to save</h4>" + errors.map {|e| "<li>#{e}</li>"}.join
      end
    end
  end

end
