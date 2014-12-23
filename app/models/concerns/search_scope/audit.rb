module SearchScope
  module Audit
    extend ActiveSupport::Concern

    included do
      scoped_search :on => [:username, :remote_address], :complete_value => true
      scoped_search :on => :audited_changes, :rename => 'changes'
      scoped_search :on => :created_at, :complete_value => true, :rename => :time, :default_order => :desc
      scoped_search :on => :action, :complete_value => { :create => 'create', :update => 'update', :delete => 'destroy' }
      scoped_search :on => :auditable_type, :complete_value => { :host => 'Host', :parameter => 'Parameter', :architecture => 'Architecture',
                                                                 :puppetclass => 'Puppetclass', :os => 'Operatingsystem', :hostgroup => 'Hostgroup',
                                                                 :template => "ConfigTemplate" }, :rename => :type

      scoped_search :in => :search_parameters, :on => :name, :complete_value => true, :rename => :parameter, :only_explicit => true
      scoped_search :in => :search_templates, :on => :name, :complete_value => true, :rename => :template, :only_explicit => true
      scoped_search :in => :search_os, :on => :name, :complete_value => true, :rename => :os, :only_explicit => true
      scoped_search :in => :search_class, :on => :name, :complete_value => true, :rename => :puppetclass, :only_explicit => true
      scoped_search :in => :search_hosts, :on => :name, :complete_value => true, :rename => :host, :only_explicit => true
      scoped_search :in => :search_hostgroups, :on => :name, :complete_value => true, :rename => :hostgroup, :only_explicit => true
      scoped_search :in => :search_users, :on => :login, :complete_value => true, :rename => :user, :only_explicit => true
    end
  end
end

