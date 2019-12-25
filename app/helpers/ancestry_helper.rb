module AncestryHelper
  # this helper is used for hostgroup names and location/organization names.  Both have ancestry
  def label_with_link(obj, max_length = 1000, authorizer = nil)
    return if obj.blank?
    options = (obj.title.to_s.size > max_length) ? { :'data-original-title' => obj.title, :rel => 'twipsy' } : {}
    nesting = obj.title.chomp(obj.name)
    nesting = truncate(nesting, :length => max_length - obj.name.to_s.size) unless nesting.to_s.empty?
    name    = truncate(obj.name, :length => max_length - nesting.to_s.size)
    link_to_if_authorized(
      content_tag(:span,
        content_tag(:span, nesting, :class => 'gray nbsp') + name, options),
      send("hash_for_edit_#{obj.class.name.to_s.tableize.singularize}_path", obj).merge(:auth_object => obj, :authorizer => authorizer))
  end
end
