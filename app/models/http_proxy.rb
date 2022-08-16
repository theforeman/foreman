require 'cgi'

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

  validates :url, :format => { :with => /\Ahttps?:\/\// }, :presence => true

  # with proc support, default_scope can no longer be chained
  # include all default scoping here
  default_scope lambda {
    with_taxonomy_scope do
      order("#{table_name}.name")
    end
  }

  scoped_search :on => :id, :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
  scoped_search :on => :name
  scoped_search :on => :url

  def full_url
    uri = URI(url)
    if username.present?
      uri.user = CGI.escape(username)
      uri.password = CGI.escape(password) if password
    end
    uri.to_s
  end

  def ssl_cert_store
    cert_store = OpenSSL::X509::Store.new
    cert_store.set_default_paths
    if cacert.present?
      Foreman::Util.add_ca_bundle_to_store(cacert, cert_store)
    end
    cert_store
  end

  def test_connection(url)
    RestClient::Request.execute(
      method: :head,
      url: url,
      proxy: full_url,
      timeout: 5,
      open_timeout: 5,
      ssl_cert_store: ssl_cert_store
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
