class OsDefaultTemplate < ActiveRecord::Base
  attr_accessible :provisioning_template_id, :template_kind_id, :operatingsystem, :operatingsystem_id

  belongs_to :provisioning_template
  belongs_to :template_kind
  belongs_to :operatingsystem

  validates :provisioning_template_id, :presence => true
  validates :template_kind_id, :presence => true, :uniqueness => {:scope => :operatingsystem_id}

  def name
    "#{operatingsystem} - #{template_kind}"
  end

  def to_label
    name
  end
end
