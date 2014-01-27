module AncestryHelper

  # this helper is used for hostgroup names and location/organization names.  Both have ancestry
  def label_with_link(obj, max_length = 1000)
    return if obj.blank?
    options = (obj.label.to_s.size > max_length) ? { :'data-original-title' => obj.label, :rel => 'twipsy' } : {}
    nesting = obj.label.to_s.gsub(/[^\/]+\/?$/, '')
    nesting = truncate(nesting, :length => max_length - obj.name.to_s.size) if nesting.to_s.size > 0
    name    = truncate(obj.name, :length => max_length - nesting.to_s.size)
    link_to_if_authorized(
      content_tag(:span,
                  content_tag(:span, nesting, :class => 'gray') + name, options),
      send("hash_for_edit_#{obj.class.name.tableize.singularize}_path", obj))
  end

end