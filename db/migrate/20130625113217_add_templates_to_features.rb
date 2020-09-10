class AddTemplatesToFeatures < ActiveRecord::Migration[4.2]
  def up
    Feature.create(:name => 'Templates')
  end

  def down
    Feature.find_by_name('Templates').destroy
  end
end
