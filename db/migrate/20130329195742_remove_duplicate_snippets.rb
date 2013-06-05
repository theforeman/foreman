class RemoveDuplicateSnippets < ActiveRecord::Migration
  def self.up
    # Remove duplicates of http_proxy added by 20110420150600_add_solaris_templates
    ConfigTemplate.destroy_all(:name => "HTTP proxy")

    # Remove duplicate added by 20120604114049_add_epel_snippets
    epels = ConfigTemplate.all(:conditions => {:name => :epel}, :order => "id ASC")
    epels.shift
    epels.each { |t| t.destroy }
  end

  def self.down
    TemplateKind.all.each do |k|
      t = ConfigTemplate.find_by_name(:http_proxy).clone
      t.name = "HTTP proxy"
      t.save(:validate => false)
    end
    ConfigTemplate.find_by_name(:epel).clone.save(:validate => false)
  end
end
