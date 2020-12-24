class RemoveOvirtUseApiFromAttr < ActiveRecord::Migration[6.0]
  def change
    compute_resources = Foreman::Model::Ovirt.unscoped
    compute_resources.each do |ovirt_resource|
      ovirt_resource.attrs.except!(:ovirt_use_v4)
      ovirt_resource.save!(validate: false)
    rescue => e
      logger.warn("could not migrate compute attributes for #{ovirt_resource.name} compute resource due to: #{e}")
    end
  end
end
