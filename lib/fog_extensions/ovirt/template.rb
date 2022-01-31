module FogExtensions
  module Ovirt
    module Template
      def full_name
        version = full_version.present? ? " (#{full_version})" : ""
        "#{name}#{version}"
      end

      def full_version
        version.version_name.presence || version.version_number
      end
    end
  end
end
