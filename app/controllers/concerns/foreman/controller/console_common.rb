module Foreman::Controller::ConsoleCommon
  def console
    render case @console[:type]
             when 'spice'
               'hosts/console/spice'
             when 'vnc'
               'hosts/console/vnc'
             when 'vmrc'
               'hosts/console/vmrc'
             else
               'hosts/console/log'
           end
  end
end
