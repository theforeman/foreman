class RemoveSignoSetting < ActiveRecord::Migration
  class FakeSetting < ActiveRecord::Base
    self.table_name = 'settings'
  end

  def up
    FakeSetting.delete_all(:name => %w(signo_url signo_sso))
  end

  def down
    # settings would be created by Setting on code version that uses it
  end
end
