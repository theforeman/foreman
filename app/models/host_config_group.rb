class HostConfigGroup < ApplicationRecord
  include Authorizable
  audited :associated_with => :host
  belongs_to :host, :polymorphic => true
  belongs_to :config_group

  validates :host_id, :uniqueness => { :scope => [:config_group_id, :host_type] }

  def check_permissions_after_save
    true
  end
end
