class OperatingsystemsPuppetclass < ActiveRecord::Base

  belongs_to :operatingsystem
  belongs_to :puppetclass

  validates_presence_of :operatingsystem_id, :puppetclass_id

  audited :associated_with => :operatingsystem

  def name
    "#{operatingsystem} - #{puppetclass}"
  end
end

