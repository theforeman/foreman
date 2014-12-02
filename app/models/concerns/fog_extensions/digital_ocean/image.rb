module FogExtensions
  module DigitalOcean
    module Image
      extend ActiveSupport::Concern

      attr_accessor :os_version

      # Override attribute :name
      included do
        define_method :name, instance_method(:full_name)
        define_method :name=, instance_method(:full_name=)
      end

      def full_name= value
        self.os_version = value
      end

      def full_name
        requires :distribution, :os_version
        "#{distribution} #{os_version}"
      end

      # Attempt guessing arch based on the name from digital ocean
      def arch
        requires :os_version
        os_version.end_with?("x64") ? "x86_64" : ( os_version.end_with?("x32") ? "i386" : nil )
      end

    end
  end
end
