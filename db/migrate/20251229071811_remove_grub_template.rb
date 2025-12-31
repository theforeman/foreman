class RemoveGrubTemplate < ActiveRecord::Migration[7.0]
  def up
    template_kind = TemplateKind.find_by(name: 'PXEGrub')
    return unless template_kind

    template_kind.os_default_templates.destroy_all

    templates = Template.where(template_kind_id: template_kind.id)
    if templates.any?
      template_ids = templates.pluck(:id)

      # Delete template_combinations to bypass EnsureNotUsedBy(:hostgroups) callback
      TemplateCombination.where(provisioning_template_id: template_ids).destroy_all

      # Unlock templates to bypass check_if_template_is_locked callback
      templates.update_all(locked: false)

      templates.destroy_all
    end

    template_kind.destroy!
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Cannot restore removed PXEGrub template"
  end
end
