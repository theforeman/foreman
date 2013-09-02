module Api
  module Version1
    extend ActiveSupport::Concern

    def api_version
      '1'
    end

  end
end