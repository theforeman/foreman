class FixPuppetclassTotalHosts < ActiveRecord::Migration
  def up
    Rake::Task['puppet:fix_total_hosts'].invoke
  end

  def down
  end
end
