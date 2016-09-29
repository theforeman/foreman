class HostConfigGroup < ActiveRecord::Base
  include Authorizable
  audited :associated_with => :host
  audited :associated_with => :hostgroup
  belongs_to :host, :polymorphic => true
  belongs_to :config_group

  validates :host_id, :uniqueness => { :scope => [:config_group_id, :host_type] }
end
