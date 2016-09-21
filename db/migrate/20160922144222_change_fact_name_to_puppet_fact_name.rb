class ChangeFactNameToPuppetFactName < ActiveRecord::Migration
  def up
    FactName.where(:type => 'FactName').update_all(:type => 'PuppetFactName')
  end

  def down
    PuppetFactName.update_all(:type => 'FactName')
  end
end
