class SmartProxyFeature < ApplicationRecord
  belongs_to :smart_proxy
  belongs_to :feature
  validates :feature, :uniqueness => {:scope => :smart_proxy_id}

  store :settings, coder: JSON

  def details
    {settings: settings, capabilities: capabilities}
  end
end
