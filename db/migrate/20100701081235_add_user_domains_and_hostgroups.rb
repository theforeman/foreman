# To suport "Edit my domain" and "edit my hostgroup" security access control we need
# a mechanism to associate a user with some domains and hostgroups
class AddUserDomainsAndHostgroups < ActiveRecord::Migration[4.2]
  def up
    create_table :user_domains, :id => false do |t|
      t.references :user
      t.references :domain
    end

    create_table :user_hostgroups, :id => false do |t|
      t.references :user
      t.references :hostgroup
    end
  end

  def down
    drop_table :user_domains
    drop_table :user_hostgroups
  end
end
