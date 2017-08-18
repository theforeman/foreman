module Foreman::Controller::ConsoleCommon
  def console
    @encrypt = Setting[:websockets_encrypt]
    if @console[:extend_content_security_policy].present?
      append_content_security_policy_directives(
        :connect_src => @console[:extend_content_security_policy]
      )
    end
    render case @console[:type]
             when 'spice'
               'hosts/console/spice'
             when 'vnc'
               'hosts/console/vnc'
             when 'webmks'
               'hosts/console/webmks'
             when 'vmrc'
               'hosts/console/vmrc'
             else
               'hosts/console/log'
           end
  end
end
