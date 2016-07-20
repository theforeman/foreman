class UpdateCentosInstallationMedia < ActiveRecord::Migration[4.2]
  def change
    Medium.unscoped.where(
      :name => 'CentOS mirror',
      :os_family => 'Redhat',
      :path => 'http://mirror.centos.org/centos/$version/os/$arch'
    ).update_all(:path => 'http://mirror.centos.org/centos/$major/os/$arch')
  end
end
