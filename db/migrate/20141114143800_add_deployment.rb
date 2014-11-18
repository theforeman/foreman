class AddDeployment < ActiveRecord::Migration

  def change
    create_table 'deployments' do |t|
      t.string 'name', :null => false
      t.references :organization
      t.references :location
      t.timestamps
    end
  end

end
