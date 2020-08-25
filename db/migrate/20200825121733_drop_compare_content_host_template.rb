class DropCompareContentHostTemplate < ActiveRecord::Migration[6.0]
  def up
    return if Foreman::Plugin.installed?('katello')
    ReportTemplate.without_auditing do
      ReportTemplate.unscoped.where(name: 'Host - compare content hosts packages').destroy_all
    end
  end
end
