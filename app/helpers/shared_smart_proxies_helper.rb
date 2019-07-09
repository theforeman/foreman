module SharedSmartProxiesHelper
  def smart_proxy_fields(f, options = {})
    object = options.fetch(:object, f.object)

    safe_join(object.registered_smart_proxies.map do |proxy_name, proxy_options|
      smart_proxy_select_f(f, proxy_name, options.merge(proxy_options))
    end)
  end

  INHERIT_TEXT = N_("inherit")

  def smart_proxy_select_f(f, resource, options)
    required = options.fetch(:required, false)
    hidden = options[:if].present? && !options[:if].call(f.object)
    can_override = options.fetch(:can_override, false)
    override = options.fetch(:override, false)
    blank = options.fetch(:blank, blank_or_inherit_f(f, resource))

    proxies = accessible_smart_proxies(f.object, resource, options[:feature])
    return if !required && proxies.blank?

    select_options = {
      :disable_button => can_override ? _(INHERIT_TEXT) : nil,
      :disable_button_enabled => override && !explicit_value?(:"#{resource}_id"),
      :user_set => user_set?(:"#{resource}_id"),
    }
    select_options[:include_blank] = blank unless required

    select_f f, :"#{resource}_id", proxies, :id, :name,
      select_options,
      :label => _(options[:label]),
      :label_help => _(options[:description]),
      :wrapper_class => "form-group #{'hide' if hidden}"
  end

  def accessible_smart_proxies(obj, resource, feature)
    list = accessible_resource_records(:smart_proxy).with_features(feature).to_a
    current = obj.public_send(resource) if obj.respond_to?(resource)
    list |= [current] if current.present?
    list
  end
end
