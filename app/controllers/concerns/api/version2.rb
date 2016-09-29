module Api
  module Version2
    extend ActiveSupport::Concern

    def api_version
      '2'
    end
  end
end
