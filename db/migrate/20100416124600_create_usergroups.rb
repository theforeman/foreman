class CreateUsergroups < ActiveRecord::Migration[4.2]
  def up
    create_table :usergroups do |t|
      t.string :name, :limit => 255
      t.timestamps null: true
    end
    create_table :usergroup_members do |t|
      t.references :member, :polymorphic => true
      t.references :usergroup
    end
  end

  def down
    drop_table :members
    drop_table :usergroups
  end
end
