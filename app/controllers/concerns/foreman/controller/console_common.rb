module Foreman::Controller::ConsoleCommon
  def console
    respond_to do |format|
      format.html do
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
      format.json { render json: { host_id: @host&.to_param, console: @console } }
    end
  end
end
