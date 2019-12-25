module BmcHelper
  def power_status(s)
    case s.try(:downcase)
    when 'on'
      "<span class='label label-success'>#{_('On')}</span>".html_safe
    when 'off'
      "<span class='label label-default'>#{_('Off')}</span>".html_safe
    else
      "<span class='label label-default'>#{_('Unknown status: %s') % s.inspect}</span>".html_safe
    end
  end

  def power_actions
    action_buttons(
      PowerManager::REAL_ACTIONS.map do |action|
        display_link_if_authorized(_(action.to_s.capitalize),
          { :action => "power", :id => @host, :power_action => action, :auth_object => @host },
          :data => { :confirm => _('Are you sure?') }, :method => :put)
      end
    )
  end

  def boot_actions
    controller_options = { :action => "ipmi_boot", :id => @host, :auth_object => @host, :permission => 'ipmi_boot' }

    confirm = _('Are you sure?')

    links = HostsController::BOOT_DEVICES.map do |device, label|
      display_link_if_authorized(_(label),
        controller_options.merge(:ipmi_device => device),
        :data => { :confirm => confirm }, :method => :put)
    end
    action_buttons("Select device", links)
  end
end
