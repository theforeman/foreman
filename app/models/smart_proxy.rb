class SmartProxy < ActiveRecord::Base
  attr_accessible :name, :url
  #TODO check if there is a way to look into the tftp_id too
  # maybe with a perdefine sql
  has_many :subnets, :foreign_key => "dhcp_id"
  has_many :domains, :foreign_key => "dns_id"
  has_and_belongs_to_many :features

  validates_uniqueness_of :name
  validates_presence_of :name, :url
  validates_format_of :url, :with => /^(http|https):\/\//, :message => "is invalid - only  http://, https:// are allowed"
  # There should be no problem with associating features before the proxy is saved as the whole operation is in a transaction
  before_save :sanitize_url, :associate_features
  before_destroy Ensure_not_used_by.new(:subnets, :domains)

  def self.name_map
    {
      "tftp"     => Feature.find_by_name("TFTP"),
      "dns"      => Feature.find_by_name("DNS"),
      "dhcp"     => Feature.find_by_name("DHCP"),
      "puppetca" => Feature.find_by_name("Puppet CA"),
      "puppet"   => Feature.find_by_name("Puppet")
    }
  end

  private

  def sanitize_url
    self.url.chomp!("/") unless url.empty?
  end

  def associate_features
    return true if Rails.env == "test"

    name_map = SmartProxy.name_map
    reason = false
    begin
      reply = ProxyAPI::Features.new(:url => url).features
      self.features = reply.map{|f| name_map[f]} unless reply.empty?
    rescue => e
      reason = e.message
    end
    unless reply
      errors.add :url, "did not respond to a request for its feature list." +
        (reason ? "The reason given was: #{reason}." : "")
      errors.add_to_base "Please check the proxy is configued and running on the host before saving."
    end
    !reply.empty?
  end
end
