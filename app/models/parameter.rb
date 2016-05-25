class Parameter < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name
  include Parameterizable::ByIdName
  include HiddenValue

  attr_accessible :name, :value, :hidden_value, :_destroy, :id, :nested, :reference_id

  validates_lengths_from_database

  include Authorizable
  validates :name, :presence => true, :no_whitespace => true

  scoped_search :on => :name, :complete_value => true

  default_scope -> { order("parameters.name") }

  before_validation :strip_whitespaces
  after_initialize :set_priority, :ensure_reference_nil

  PRIORITY = {:common_parameter => 0, :domain_parameter => 1, :subnet_parameter => 2, :os_parameter => 3, :group_parameter => 4, :host_parameter => 5}

  def self.reassign_priorities
    # priorities will be reassigned because of after_initialize
    find_in_batches do |params|
      params.each { |param| param.update_attribute(:priority, param.priority) }
    end
  end

  private

  def set_priority
    t = read_attribute(:type)
    self.priority = PRIORITY[t.to_s.underscore.to_sym] unless t.blank?
  end

  def strip_whitespaces
    self.name = self.name.strip unless name.blank? # when name string comes from a hash key, it's frozen and cannot be modified
    self.value.strip! unless value.blank?
  end

  # hack fix for Rails 3.2.8. Not needed for 3.2.18.
  def ensure_reference_nil
    self.reference_id = nil if self.new_record? && self.reference_id == 1
  end

end
