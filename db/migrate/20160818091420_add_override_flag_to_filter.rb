class AddOverrideFlagToFilter < ActiveRecord::Migration
  class FakeFilter < ActiveRecord::Base
    self.table_name = 'filters'
  end

  def up
    add_column :filters, :override, :boolean, :default => false, :null => false

    FakeFilter.where.not(:taxonomy_search => nil).update_all(:override => true)
  end

  def down
    remove_column :filters, :override
  end
end
