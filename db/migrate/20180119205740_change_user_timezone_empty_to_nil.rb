class ChangeUserTimezoneEmptyToNil < ActiveRecord::Migration[4.2]
  class FakeUser < ApplicationRecord
    self.table_name = 'users'
  end

  def up
    FakeUser.where(:timezone => '').update_all(:timezone => nil)
  end

  def down
    # no action: we don't know which data should be '' and which nil
  end
end
