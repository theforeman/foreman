module FogExtensions
  module AWS
    module Tag
      extend ActiveSupport::Concern

      def id
        "#{resource_id}-#{key}"
      end
    end
  end
end
