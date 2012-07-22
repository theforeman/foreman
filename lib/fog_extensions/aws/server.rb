module FogExtensions
  module AWS
    module Server
      def to_s
        tags["Name"]
      end

      def name
        to_s
      end

    end
  end
end