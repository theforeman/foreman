class RemoveDuplicateSnippets < ActiveRecord::Migration[4.2]
  class FakeConfigTemplate < ApplicationRecord
    self.table_name = 'config_templates'
  end

  def up
    # Remove duplicates of http_proxy added by 20110420150600_add_solaris_templates
    FakeConfigTemplate.where(:name => "HTTP proxy").destroy_all

    # Remove duplicate added by 20120604114049_add_epel_snippets
    epels = FakeConfigTemplate.where(:name => :epel).order("id ASC").to_a
    epels.shift
    epels.each { |t| t.destroy }
  end

  def down
    TemplateKind.all.each do |k|
      t = FakeConfigTemplate.find_by_name(:http_proxy).clone
      t.name = "HTTP proxy"
      t.save(:validate => false)
    end
    FakeConfigTemplate.find_by_name(:epel).clone.save(:validate => false)
  end
end
