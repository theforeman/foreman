module FogExtensions
  module Ovirt
    module Volume
      extend ActiveSupport::Concern
      def as_json(options = { })
        size_gb
        super options
      end
    end
  end
end
