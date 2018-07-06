class SmartProxyFeature < ApplicationRecord
  belongs_to :smart_proxy
  belongs_to :feature
  validates :feature, :uniqueness => {:scope => :smart_proxy}

  serialize :capabilities, Array
  store :settings, coder: JSON
end
