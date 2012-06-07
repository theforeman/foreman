class UserDataForComputeResources < ActiveRecord::Migration
  def self.up
    %w[user_data].each do |type|
      TemplateKind.create(:name => type)
    end
  end

  def self.down
    execute "DELETE FROM template_kinds WHERE name like 'user_data';"
  end
end
