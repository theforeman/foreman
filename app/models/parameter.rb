class Parameter < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name

  validates_lengths_from_database

  belongs_to_host :foreign_key => :reference_id
  include Authorizable
  validates :name, :presence => true, :format => {:with => /\A\S*\Z/, :message => N_("can't contain white spaces")}
  validates :reference_id, :presence => {:message => N_("parameters require an associated domain, operating system, host or host group")}, :unless => Proc.new {|p| p.nested or p.is_a? CommonParameter}

  scoped_search :on => :name, :complete_value => true

  default_scope lambda { order("parameters.name") }

  attr_accessor :nested
  before_validation :strip_whitespaces
  after_initialize :set_priority, :ensure_reference_nil

  PRIORITY = {:common_parameter => 0, :domain_parameter => 1, :os_parameter => 2, :group_parameter => 3, :host_parameter => 4}

  def self.reassign_priorities
    # priorities will be reassigned because of after_initialize
    find_in_batches do |params|
      params.each { |param| param.update_attribute(:priority, param.priority) }
    end
  end

  def safe_value
    self.hidden_value? ? self.hidden_value : self.value
  end

  def hidden_value
    self.class.hidden_value
  end

  def self.hidden_value
    '*' * 5
  end

  private

  def set_priority
    t = read_attribute(:type)
    self.priority = PRIORITY[t.to_s.underscore.to_sym] unless t.blank?
  end

  def strip_whitespaces
    self.name = self.name.strip  unless name.blank? # when name string comes from a hash key, it's frozen and cannot be modified
    self.value.strip! unless value.blank?
  end

  # hack fix for Rails 3.2.8. Not needed for 3.2.18.
  # related to **accepts_nested_attributes_for** on UI form (not API)
  # which incorrectly assigns foreign key to 1 when attributes are from STI class (DomainParamter, HostParameter, etc)
  def ensure_reference_nil
    self.reference_id = nil if self.new_record? && self.reference_id == 1 && Rails.version == '3.2.8'
  end

end
