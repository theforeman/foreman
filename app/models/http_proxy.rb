require 'cgi'

class HttpProxy < ApplicationRecord
  audited
  include Authorizable
  include Taxonomix
  include Encryptable
  include NormalizeCacert

  extend FriendlyId
  include Parameterizable::ByIdName

  encrypts :password
  friendly_id :name

  has_many :compute_resources

  before_validation :nilify_empty_credentials

  validates :name, :presence => true, :uniqueness => true

  validates :url, :format => { :with => /\Ahttps?:\/\// }, :presence => true
  validates :cacert, :cacert => true

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
    Foreman::Util.ssl_cert_store(cacert)
  end

  def test_connection(url)
    options = {
      method: :head,
      url: url,
      proxy: full_url,
      timeout: 5,
      open_timeout: 5,
    }
    store = ssl_cert_store
    options[:ssl_cert_store] = store if store
    RestClient::Request.execute(options)
  rescue Excon::Error::Socket => e
    e.message
  end

  private

  def nilify_empty_credentials
    self.username = nil if username.empty?
    self.password = nil if password.empty?
  end
end
