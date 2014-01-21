module BmcHelper

  def power_status host
    if host.power.state.downcase == 'on'
      "<span class='label label-success'>#{_('On')}</span>".html_safe
    else
      "<span class='label label-default'>#{_('Off')}</span>".html_safe
    end
  end

  def power_actions host
    toolbar_action_buttons(
      host.power.supported_actions.map do |action|
        display_link_if_authorized(_(action.to_s.capitalize), { :action => "power", :id => @host, :power_action => action},
                                   :confirm => _('Are you sure?'), :method => :put)
      end
    )
  end

  def boot_actions
    controller_options = { :action => "ipmi_boot", :id => @host }

    confirm = _('Are you sure?')

    links = HostsController::BOOT_DEVICES.map do |device,label|
       display_link_if_authorized(_(label), controller_options.merge(:ipmi_device => device),
                                  :confirm => confirm, :method => :put)
    end
    action_buttons("Select device", links)
  end
end
