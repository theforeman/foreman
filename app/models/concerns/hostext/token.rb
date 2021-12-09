module Hostext
  module Token
    extend ActiveSupport::Concern

    included do
      has_one :token, :foreign_key => :host_id, :dependent => :destroy, :inverse_of => :host, :class_name => 'Token::Build'

      scope :for_token, ->(token) { joins(:token).where(:tokens => { :value => token }).where("expires >= ?", Time.now.utc.to_s(:db)).select('hosts.*') }
      scope :for_token_when_built, ->(token) { joins(:token).where(:tokens => { :value => token }).select('hosts.*') }

      before_validation :refresh_token_on_build
    end

    # Sets and expire provisioning tokens
    # this has to happen post validation and before the orchesration queue is starting to
    # process, as the token value is required within the tftp config file manipulations
    def refresh_token_on_build
      # new server in build mode
      set_token if new_record? && build?
      # existing server change build mode
      if respond_to?(:old) && old && build? != old.build?
        build? ? set_token : expire_token
      end
    end

    def set_token
      return unless Setting[:token_duration] != 0
      value = Foreman.uuid
      expires = Time.now.utc + Setting[:token_duration].minutes
      logger.debug do
        # improve debugging options but avoid leaking the token via logs
        sha = Digest::SHA256.hexdigest(value)
        "Building token starting with #{value[0..5]} SHA256:#{sha}"
      end
      build_token(:value => value, :expires => expires)
    end

    def token_expired?
      return false unless Setting[:token_duration] != 0 && token.present?
      token.expires < Time.now.utc
    end

    def expire_token
      token.delete if token.present?
    end
  end
end
