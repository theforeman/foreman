module CommonParametersHelper
  # Return true if user is authorized for controller/action OR controller/action@type, otherwise false
  # third argument may be specific object (usually for edit and destroy actions)
  def authorized_via_my_scope(controller, action, object = nil)
    authorized_for(:controller => controller, :action => action, :auth_object => object)
  end

  def parameters_title
    _("Parameters that would be associated with hosts in this %s") % (type)
  end

  def parameter_value_field(value)
    source_name = value[:source_name] ? "(#{value[:source_name]})" : nil
    value_content_tag(value[:safe_value],[],value[:safe_value], [],
                      popover('', _("<b>Source:</b> %{type} %{name}") % {:type => _(value[:source].to_s), :name => source_name}, 'data-placement' => 'top'))
  end

  def use_puppet_default_help link_title = nil, title = _("Use Puppet default")
    popover(link_title, _("Do not send this parameter via the ENC.<br>Puppet will use the value defined in the manifest."), :title => title)
  end
end
