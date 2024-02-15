class RemoveSubscriptionEntitlementsReport < ActiveRecord::Migration[6.1]
  def change
    subscription_entitlement_report = ReportTemplate.unscoped.find_by(name: "Subscription - Entitlement Report")
    return unless subscription_entitlement_report
    template_inputs = TemplateInput.where(template_id: subscription_entitlement_report.id)
    template_inputs&.delete_all
    subscription_entitlement_report&.delete
  end
end
