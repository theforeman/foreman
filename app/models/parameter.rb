class Parameter < ActiveRecord::Base
  belongs_to_host :foreign_key => :reference_id
  include Authorization

  validates_presence_of   :name, :value
  validates_format_of     :name,  :without => /\s/, :message => "can't contain white spaces"

  validates_presence_of :reference_id, :message => "parameters require an associated domain, host or hostgroup", :unless => Proc.new {|p| p.nested or p.is_a? CommonParameter}

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
