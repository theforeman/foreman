class HttpProxy < ApplicationRecord
  include Authorizable
  include Taxonomix
  include Encryptable

  extend FriendlyId

  encrypts :password
  friendly_id :name

  has_many :compute_resources

  validates :url, :presence => true
  validates :url, :format => URI::regexp(["http", "https"])

  scoped_search :on => :name
  scoped_search :on => :url

  def full_url
    uri = URI(url)
    uri.user = username unless username.blank?
    uri.password = password unless username.blank?
    uri.to_s
  end

  def test_connection(url)
    raise self.errors.full_messages.join("\n") unless self.valid?

    RestClient::Request.execute(method: :head, url: url, proxy: full_url)
  rescue Excon::Error::Socket => e
    e.message
  end
end
