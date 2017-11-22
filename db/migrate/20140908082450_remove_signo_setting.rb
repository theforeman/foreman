class RemoveSignoSetting < ActiveRecord::Migration[4.2]
  class FakeSetting < ApplicationRecord
    self.table_name = 'settings'
  end

  def up
    FakeSetting.where(:name => %w(signo_url signo_sso)).delete_all
  end

  def down
    # settings would be created by Setting on code version that uses it
  end
end
