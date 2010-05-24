class Parameter < ActiveRecord::Base
  acts_as_audited
  validates_presence_of   :name, :value
  validates_format_of     :name, :value, :with => /\A(\S+\s?)+\Z/, :message => "can't be blank or contain trailing white space"

  validates_presence_of :reference_id, :message => "parameters require an associated domain, host or hostgroup", :unless => 'nested or self.is_a? CommonParameter'

  attr_accessor :nested
end
