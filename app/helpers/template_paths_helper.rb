module TemplatePathsHelper
  def template_route_prefix(type)
    type = type.to_s
    if type.constantize <= ::Template
      type.underscore.pluralize
    else
      raise "'#{type}' is not a template descendant"
    end
  rescue NameError
    raise "unknown type '#{type}'"
  end

  def template_url_for(type)
    public_send("#{template_route_prefix(type)}_url")
  end

  def template_path_for(type)
    public_send("#{template_route_prefix(type)}_path")
  end

  def template_hash_for_member(template, member = nil)
    member = "#{member}_" if member.present?
    # hash_for is protected method
    if template.id.present?
      send("hash_for_#{member}#{template_route_prefix(template.class).singularize}_path", :id => template)
    else
      send("hash_for_#{member}#{template_route_prefix(template.class)}_path")
    end
  end

  def render_if_exists(partial)
    partial_exists = lookup_context.find_all(partial).any?
    if partial_exists
      render :partial => partial.split("_").last
    else
      logger.debug("Did not load partial #{partial} because it could not be found.")
      nil
    end
  end
end
