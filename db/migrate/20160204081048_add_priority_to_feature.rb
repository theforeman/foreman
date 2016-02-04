require Rails.root + 'db/seeds.d/11-smart_proxy_features'

class AddPriorityToFeature < ActiveRecord::Migration
  def change
    add_column :features, :priority, :integer, :default => Feature::MAX_PRIORITY, :null => false
    seed_smart_proxy_features
  end
end
