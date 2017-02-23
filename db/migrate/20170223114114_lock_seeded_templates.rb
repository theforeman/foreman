require Rails.root + 'db/seeds.d/07-data.rb'
require Rails.root + 'db/seeds.d/08-data.rb'

class LockSeededTemplates < ActiveRecord::Migration
  def up
    names = (SEEDED_TEMPLATES + SEEDED_PARTITION_TABLES).map { |attrs| attrs[:name] }
    Template.where(:name => names).update_all(:locked => true)
  end

  def down
    names = (SEEDED_TEMPLATES + SEEDED_PARTITION_TABLES).map { |attrs| attrs[:name] }
    Template.where(:name => names).update_all(:locked => false)
  end
end
