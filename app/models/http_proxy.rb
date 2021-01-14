class HttpProxy < ApplicationRecord
  audited
  include Authorizable
  include Taxonomix
  include Encryptable

  extend FriendlyId
  include Parameterizable::ByIdName

  encrypts :password
  friendly_id :name

  has_many :compute_resources

  before_validation :nilify_empty_credentials

  validates :name, :presence => true, :uniqueness => true

  validates :url, :presence => true
  validates :url, :format => URI.regexp(["http", "https"])

  # with proc support, default_scope can no longer be chained
  # include all default scoping here
  default_scope lambda {
    with_taxonomy_scope do
      order("#{table_name}.name")
    end
  }

  scoped_search :on => :name
  scoped_search :on => :url

  def full_url
    uri = URI(url)
    uri.user = username if username.present?
    uri.password = password if username.present?
    uri.to_s
  end

  def test_connection(url)
    RestClient::Request.execute(
      method: :head,
      url: url,
      proxy: full_url,
      timeout: 5,
      open_timeout: 5
    )
  rescue Excon::Error::Socket => e
    e.message
  end

  private

  def nilify_empty_credentials
    self.username = nil if username.empty?
    self.password = nil if password.empty?
  end
end
