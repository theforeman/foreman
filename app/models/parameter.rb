class Parameter < ActiveRecord::Base
  belongs_to :host, :foreign_key => :reference_id
  include Authorization

  validates_presence_of   :name, :value
  validates_format_of     :name, :value, :with => /^.*\S$/, :message => "can't be blank or contain trailing white space"

  validates_presence_of :reference_id, :message => "parameters require an associated domain, host or hostgroup", :unless => Proc.new {|p| p.nested or p.is_a? CommonParameter}

  attr_accessor :nested
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

end
