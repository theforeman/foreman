module Foreman
  module Renderer
    module Scope
      module Macros
        module KickstartNetworking
          extend ApipieDSL::Module

          apipie :class, 'Kickstart network configuration macros' do
            name 'Kickstart networking'
            sections only: %w[all provisioning]
          end

          apipie :method, 'Returns host interfaces in dependency order for Kickstart network directives' do
            returns Array, desc: 'Interfaces with dependencies before the interfaces that depend on them'
          end
          def kickstart_network_interfaces
            pending = host.interfaces.reject { |iface| iface.bmc? }
            ordered = []

            until pending.empty?
              ready = pending.select do |iface|
                dependencies = []
                dependencies.concat(iface.attached_devices_identifiers) if iface.bond? || iface.bridge?
                dependencies << iface.attached_to if iface.virtual? && iface.attached_to.present?

                dependencies.all? do |identifier|
                  pending.none? { |candidate| candidate.identifier == identifier }
                end
              end

              if ready.empty?
                ordered.concat(pending.sort_by(&:identifier))
                break
              end

              ready.sort_by! { |iface| [iface.provision? ? 0 : 1, iface.identifier] }
              ordered.concat(ready)
              pending -= ready
            end

            ordered
          end
        end
      end
    end
  end
end
