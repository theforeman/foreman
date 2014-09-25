class ChangeChefProxyFeatureName < ActiveRecord::Migration
  class FakeFeature < ActiveRecord::Base
    self.table_name = Feature.table_name
  end

  def up
    FakeFeature.where(:name => 'Chef Proxy').update_all(:name => 'Chef')
  end

  def down
    FakeFeature.where(:name => 'Chef').update_all(:name => 'Chef Proxy')
  end
end
