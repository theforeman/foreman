class ProvisioningTemplatesController < TemplatesController
  include Foreman::Controller::Parameters::ProvisioningTemplate

  def build_pxe_default
    status, msg = ProvisioningTemplate.authorized(:deploy_provisioning_templates).build_pxe_default(self)
    status == 200 ? notice(msg) : error(msg)
    redirect_to :back
  end
end
