class ProvisioningTemplatesController < TemplatesController
  include Foreman::Controller::Parameters::ProvisioningTemplate
  helper_method :documentation_anchor

  def build_pxe_default
    status, msg = ProvisioningTemplate.authorized(:deploy_provisioning_templates).build_pxe_default
    (status == :ok) ? success(msg) : error(msg)
    redirect_back(fallback_location: provisioning_templates_path)
  end

  def documentation_anchor
    '4.4.3ProvisioningTemplates'
  end
end
