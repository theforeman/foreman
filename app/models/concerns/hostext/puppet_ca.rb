module Hostext
  module PuppetCA
    extend ActiveSupport::Concern

    included do
      has_one :puppetca_token, :foreign_key => :host_id, :dependent => :destroy, :inverse_of => :host, :class_name => 'Token::PuppetCA'
    end
  end
end
