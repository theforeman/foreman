module AutosignHelper

  def autosign_form
    link_to "New", new_smart_proxy_autosign_path(@proxy) if authorized_for(:controller => "SmartProxies::Autosign", :action => :create, :auth_object => @proxy)
  end
end
