module FogExtensions
  module Ovirt
    module Volume
      def as_json(options={ })
        size_gb
        super options
      end
    end
  end
end

