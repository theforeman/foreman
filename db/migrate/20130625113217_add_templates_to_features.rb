class AddTemplatesToFeatures < ActiveRecord::Migration
  def up
    Feature.create(:name => 'Templates')
  end

  def down
    Feature.find_by_name('Templates').destroy
  end
end
