class TemplateKindRegistration < ActiveRecord::Migration[6.0]
  def up
    host_init_config_kind = TemplateKind.unscoped.find_or_create_by(name: 'host_init_config')
    registration_kind = TemplateKind.unscoped.find_by(name: 'registration')

    # Migrate Host registration templates to host_init_config kind
    ProvisioningTemplate.unscoped
                        .where(template_kind: registration_kind)
                        .where.not(name: [Setting[:default_global_registration_item], 'Global Registration'])
                        .update_all(template_kind_id: host_init_config_kind.id)

    # Rename 'Linux registration default' to 'Linux host_init_config default'
    ProvisioningTemplate.unscoped
                        .where(name: 'Linux registration default')
                        .update_all(name: Setting[:default_host_init_config_template])

    # Unassign operating systems from registration templates
    # (Registration templates are not allowed to be assigned to OS)
    registration_templates = ProvisioningTemplate.unscoped.where(template_kind: registration_kind)
    registration_templates.each { |rt| rt.operatingsystems = [] }

    # Assign default host_init_config template to all operating systems
    # and change registration association to the host_init_config
    template = ProvisioningTemplate.unscoped.find_by_name(Setting[:default_host_init_config_template])
    Operatingsystem.all.each do |os|
      template.operatingsystems << os unless template.operatingsystems.include?(os)

      os_default_registration = OsDefaultTemplate.find_by(template_kind: registration_kind, operatingsystem: os)
      if os_default_registration
        os_default_registration.update(template_kind_id: host_init_config_kind.id)
      else
        OsDefaultTemplate.create template_kind: host_init_config_kind,
                                 provisioning_template: template,
                                 operatingsystem: os
      end
    end
  end

  def down
    host_init_config_kind = TemplateKind.unscoped.find_by(name: 'host_init_config')
    registration_kind = TemplateKind.unscoped.find_by(name: 'registration')

    # Rename 'Linux host_init_config default' back to 'Linux registration default'
    ProvisioningTemplate.unscoped.find_by_name(Setting[:default_host_init_config_template])
                        .update(name: 'Linux registration default')

    # Migrate host_init_config templates back to Host registration templates kind
    ProvisioningTemplate.unscoped.where(template_kind_id: host_init_config_kind.id)
                        .update_all(template_kind_id: registration_kind.id)

    OsDefaultTemplate.where(template_kind_id: host_init_config_kind.id)
                     .update_all(template_kind_id: registration_kind.id)
  end
end
