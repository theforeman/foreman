module Types
  module Networks
    class Union < Types::BaseUnion
      description 'Networks that are defined for a compute resource'
      possible_types Vmware

      def self.resolve_type(object, context)
        return Vmware if object.is_a?(Fog::Vsphere::Compute::Network)

        raise UnknownNetworkType.new(N_('Cannot resolve network type for %s'), object.class)
      end

      class UnknownNetworkType < ::Foreman::Exception; end
    end
  end
end
