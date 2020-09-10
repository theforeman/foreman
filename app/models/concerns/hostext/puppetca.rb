module Hostext
  module Puppetca
    extend ActiveSupport::Concern

    included do
      has_one :puppetca_token, :foreign_key => :host_id, :dependent => :destroy, :inverse_of => :host, :class_name => 'Token::Puppetca'
    end
  end
end
