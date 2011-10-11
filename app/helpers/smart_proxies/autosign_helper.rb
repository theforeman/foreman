module SmartProxies::AutosignHelper

  def autosign_form
    link_to "New", new_smart_proxy_autosign_path(@proxy) if authorized_for("SmartProxies::Autosign", :create)
  end
end
