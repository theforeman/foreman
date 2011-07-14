require_dependency "acts_as_audited"

# The audit class is part of acts_as_audited plugin
# we reopen here to add search functionality

class Audit < ActiveRecord::Base
  belongs_to :search_users, :class_name => 'User',            :foreign_key => :user_id
  belongs_to :search_hosts, :class_name => 'Host',            :foreign_key => :auditable_id, :conditions => "auditable_type = 'Puppet::Rails::Host'"
  belongs_to :search_parameters, :class_name => 'Parameter',  :foreign_key => :auditable_id, :conditions => "auditable_type = 'Parameter'"
  belongs_to :search_os, :class_name => 'Operatingsystem',    :foreign_key => :auditable_id, :conditions => "auditable_type = 'Operatingsystem'"
  belongs_to :search_class, :class_name => 'Puppetclass',     :foreign_key => :auditable_id, :conditions => "auditable_type = 'Puppetclass'"

  scoped_search :on => :username, :complete_value => true
  scoped_search :on => :created_at, :complete_value => true, :rename => :changed_at, :default_order => :desc
  scoped_search :on => :action, :complete_value => {:create => 'create', :update => 'update', :delete => 'delete'}
  scoped_search :on => :auditable_type, :complete_value => {:host => 'Puppet::Rails::Host',:parameter => 'Parameter', :architecture => 'Architecture', :class => 'Puppetclass', :os => 'Operatingsystem', :group => 'Hostgroup'}, :rename => :changed

  scoped_search :in => :search_parameters,   :on => :name,  :complete_value => true, :rename => :parameter
  scoped_search :in => :search_os,           :on => :name,  :complete_value => true, :rename => :os
  scoped_search :in => :search_class,        :on => :name,  :complete_value => true, :rename => :class
  scoped_search :in => :search_hosts,        :on => :name,  :complete_value => true, :rename => :host
  scoped_search :in => :search_users,        :on => :login, :complete_value => true, :rename => :user

end
