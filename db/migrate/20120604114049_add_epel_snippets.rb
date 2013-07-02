class AddEpelSnippets < ActiveRecord::Migration
  class ConfigTemplate < ActiveRecord::Base; end
  def self.up
    ConfigTemplate.find_or_create_by_name( :name => "epel", :snippet => true, :template => File.read("#{Rails.root}/app/views/unattended/snippets/_epel.erb"))
  end

  def self.down
    ConfigTemplate.find_by_name("epel").try(:destroy)
  end
end
