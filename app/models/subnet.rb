class Subnet < ActiveRecord::Base
  has_many :hosts, :through => :domain
  has_many :sps, :through => :hosts
  belongs_to :domain
  validates_presence_of   :number, :mask
  validates_uniqueness_of :number
  validates_format_of     :number,     :with => /(\d{1,3}\.){3}\d{1,3}/, :message => "self.number is invalid"
  validates_format_of     :mask,       :with => /(\d{1,3}\.){3}\d{1,3}/
  validates_uniqueness_of :name, :scope => :domain_id
  validates_associated :domain

  before_destroy Ensure_not_used_by.new(:hosts, :sps)

  # Subnets are displayed in the form of their network number/network mask
  def to_label
    "#{domain.name}: #{number}/#{mask}"
  end

  # If a subnet object exists then it can never be empty
  def empty?
    false
  end
  # Given an IP returns the subnet that contains that IP
  # [+ip+] : "doted quad" string
  # Returns : Subnet object
  def self.find_subnet(ip)
    Subnet.find(:all).each do |subnet|
      return subnet if subnet.contains ip
    end
    nil
  end

  def detailedName
    return "#{self.name}@#{self.number}/#{self.mask}"
  end
end

