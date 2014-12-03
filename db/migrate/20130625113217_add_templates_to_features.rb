class AddTemplatesToFeatures < ActiveRecord::Migration
  def self.up
    Feature.create(:name => 'Templates')
  end

  def self.down
    Feature.find_by_name('Templates').destroy
  end
end
