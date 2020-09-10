class ChangeFactNameToPuppetFactName < ActiveRecord::Migration[4.2]
  def up
    FactName.where(:type => 'FactName').update_all(:type => 'PuppetFactName')
  end

  def down
    PuppetFactName.update_all(:type => 'FactName')
  end
end
