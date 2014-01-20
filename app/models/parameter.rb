class Parameter < ActiveRecord::Base
  belongs_to_host :foreign_key => :reference_id
  include Authorizable

  validates :value, :presence => true
  validates :name, :presence => true, :format => {:with => /\A\S*\Z/, :message => N_("can't contain white spaces")}
  validates :reference_id, :presence => {:message => N_("parameters require an associated domain, host or host group")}, :unless => Proc.new {|p| p.nested or p.is_a? CommonParameter}

  default_scope lambda { order("parameters.name") }

  attr_accessor :nested
  before_validation :strip_whitespaces
  after_initialize :set_priority

  PRIORITY = {:common_parameter => 0, :domain_parameter => 1, :os_parameter => 2, :group_parameter => 3 , :host_parameter => 4}

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
    self.name = self.name.strip  unless name.blank? # when name string comes from a hash key, it's frozen and cannot be modified
    self.value.strip! unless value.blank?
  end
end
