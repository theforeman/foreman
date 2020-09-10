class RenameReportTemplates < ActiveRecord::Migration[5.2]
  TEMPLATE_NAMES = {
    "Ansible Inventory" => "Ansible - Ansible Inventory",
    "Applicable errata" => "Host - Applicable Errata",
    "Applied Errata" => "Host - Applied Errata",
    "Entitlements" => "Subscription - Entitlement Report",
    "Host statuses" => "Host - Statuses",
    "Registered hosts" => "Host - Registered Content Hosts",
    "Registered users" => "User - Registered Users",
    "Subscriptions" => "Subscription - General Report",
  }

  def up
    TEMPLATE_NAMES.each do |from, to|
      token = SecureRandom.base64(5)
      ReportTemplate.unscoped.find_by(name: to)&.update_columns(:name => "#{to} Backup #{token}")
      ReportTemplate.unscoped.find_by(name: from)&.update_columns(:name => to)
    end
  end

  def down
    TEMPLATE_NAMES.each do |from, to|
      ReportTemplate.unscoped.find_by(name: from)&.delete
      ReportTemplate.unscoped.find_by(name: to)&.update_columns(:name => from)
    end
  end
end
