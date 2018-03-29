class RemoveV3FromOvirtCrUrl < ActiveRecord::Migration[5.1]
  def up
    Foreman::Model::Ovirt.unscoped.where("url LIKE '%/v3'").each do |ovirt_cr|
      ovirt_cr.update_attribute(:url, ovirt_cr.url.chomp('/v3'))
    end
  end

  def down
    Foreman::Model::Ovirt.unscoped.where.not('attrs LIKE ?', '%ovirt_use_v4: true%').each do |ovirt_cr|
      ovirt_cr.update_attribute(:url, ovirt_cr.url + '/v3')
    end
  end
end
