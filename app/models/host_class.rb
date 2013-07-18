class HostClass < ActiveRecord::Base
  include Authorization
  audited :associated_with => :host, :allow_mass_assignment => true
  belongs_to_host :foreign_key => :host_id
  belongs_to :puppetclass

  validates_presence_of :host_id, :puppetclass_id
  validates :puppetclass_id, :uniqueness => {:scope => :host_id}

  def name
    "#{host} - #{puppetclass}"
  end

  private

  def enforce_permissions operation
    if operation == "edit" and new_record?
      return true # We get called again with the operation being set to create
    end
    if User.current.allowed_to?(:edit_classes) && Host.my_hosts.pluck(:id).include?(self.host_id)
      return true
    else
      errors.add(:base, _("You do not have permission to edit puppetclasses on this host"))
      return false
    end
  end

end
