class RenameCentOs7InstallMedia < ActiveRecord::Migration[6.0]
  def up
    Medium.where(name: "CentOS mirror").update_all(name: "CentOS 7 mirror")
  end

  def down
    Medium.where(name: "CentOS 7 mirror").update_all(name: "CentOS mirror")
  end
end
