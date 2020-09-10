# To suport "Edit my domain" and "edit my hostgroup" security access control we need
# a mechanism to associate a user with a fact and a criria for thet fact to evaluate against
class CreateUserFacts < ActiveRecord::Migration[4.2]
  def up
    create_table :user_facts do |t|
      t.references :user
      t.references :fact_name
      t.string     :criteria, :limit => 255
      t.string     :operator, :limit => 3, :default => "="
      t.string     :andor,    :limit => 3, :default => "or"
      t.timestamps null: true
    end
  end

  def down
    drop_table :user_facts
  end
end
