class RenameCentosStreamMirrorToCentos < ActiveRecord::Migration[6.1]
  def up
    Medium.unscoped.where(name: "CentOS Stream 9 mirror").update_all(name: "CentOS mirror")
  end

  def down
    Medium.unscoped.where(name: "CentOS mirror").update_all(name: "CentOS Stream 9 mirror")
  end
end
