class SmartProxy < ActiveRecord::Base
  attr_accessible :name, :url
  #TODO check if there is a way to look into the tftp_id too
  # maybe with a perdefine sql
  has_many :subnets, :foreign_key => "dhcp_id"
  has_many :domains, :foreign_key => "dns_id"

  validates_uniqueness_of :name
  validates_presence_of :name, :url
  validates_format_of :url, :with => /^(http|https):\/\//, :message => "is invalid - only  http://, https:// are allowed"
  before_save :sanitaize_url, :try_to_connect
  before_destroy Ensure_not_used_by.new(:subnets, :domains)

  private

  def sanitaize_url
    self.url.chomp!("/") unless url.empty?
  end

  def try_to_connect
    true
  end
end
