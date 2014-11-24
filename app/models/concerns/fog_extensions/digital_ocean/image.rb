module FogExtensions
  module DigitalOcean
    module Image
      extend ActiveSupport::Concern
      def to_label
        "#{distribution} #{name}"
      end
    end
  end
end
