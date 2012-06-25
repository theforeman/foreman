class AddEpelSnippets < ActiveRecord::Migration
  def self.up
    ConfigTemplate.without_auditing {ConfigTemplate.create( :name => "epel", :snippet => true, :template => File.read("#{Rails.root}/app/views/unattended/snippets/_epel.erb"))}
  end

  def self.down
    ConfigTemplate.find_by_name("epel").try(:destroy)
  end
end
