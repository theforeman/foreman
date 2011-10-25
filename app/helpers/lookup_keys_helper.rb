module LookupKeysHelper

  def remove_child_link(name, f, opts = {})
    opts[:class] = [opts[:class], "remove_nested_fields btn small danger"].compact.join(" ")
    f.hidden_field(:_destroy) + link_to(name, "javascript:void(0)", opts)
  end

  def add_child_link(name, association, opts = {})
    opts[:class] = [opts[:class], "add_nested_fields btn small success"].compact.join(" ")
    opts[:"data-association"] = association
    link_to(name, "javascript:void(0)", opts)
  end

  def new_child_fields_template(form_builder, association, options = { })
    options[:object]             ||= form_builder.object.class.reflect_on_association(association).klass.new
    options[:partial]            ||= association.to_s.singularize
    options[:form_builder_local] ||= :f

    content_tag(:div, :id => "#{association}_fields_template", :style => "display: none") do
      form_builder.fields_for(association, options[:object], :child_index => "new_#{association}") do |f|
        render(:partial => options[:partial], :locals => { options[:form_builder_local] => f })
      end
    end
  end
end
