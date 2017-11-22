class ChangePreseedDefaultPxeGrub2Kind < ActiveRecord::Migration[4.2]
  def update_kind
    kind = TemplateKind.find_by_name(:PXEGrub2)
    tmpl = ProvisioningTemplate.unscoped.find_by_name("Preseed default PXEGrub2")
    tmpl.update_attribute(:template_kind, kind) if tmpl && kind
  end

  def up
    if User.unscoped.find_by_login(User::ANONYMOUS_ADMIN).present?
      User.as_anonymous_admin do
        update_kind
      end
    else
      User.without_auditing do
        update_kind
      end
    end
  end
end
