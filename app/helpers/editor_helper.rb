module EditorHelper
  def template_name_attribute(template)
    "#{template.to_s.underscore}[template]"
  end
end
