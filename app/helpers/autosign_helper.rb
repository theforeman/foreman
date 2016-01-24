module AutosignHelper
  def autosign_form
    button_tag(_("New"), :type => 'button', :class => 'btn btn-primary fr', :data => {:toggle => 'modal', :target =>'#autosignModal'}) if authorized_for(:controller => "SmartProxies::Autosign", :action => :create, :auth_object => @proxy)
  end
end
