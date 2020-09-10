class RemoveLegacyPuppetHostnameSetting < ActiveRecord::Migration[5.1]
  class FakeSetting < ApplicationRecord
    self.table_name = 'settings'
  end

  def up
    FakeSetting.where(:name => 'legacy_puppet_hostname').delete_all
  end

  def down
    # settings would be created by Setting on code version that uses it
  end
end
