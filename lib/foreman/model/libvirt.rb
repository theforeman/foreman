module Foreman::Model
  class Libvirt < ComputeResource

    # we default to destroy the VM's stroage as well.
    def destroy_vm uuid, args = {}
      find_vm_by_uuid(uuid).destroy({:destroy_volumes => true}.merge(args))
    end

    def self.model_name
      ComputeResource.model_name
    end

    def vm_instance_defaults
      {
        :memory_size            => 512*1024,
        :volume_format_type     => "raw",
        :volume_capicity        => "10G",
        :volume_allocation      => "0G",
        :volume_pool_name       => "default",
        :network_interface_type => "bridge",
        :network_bridge_name    => "br180",
        :pxe                    => true,
      }
    end

    def max_cpu_count
      hypervisor.max_vcpus
    end

    def max_memory
      hypervisor.memory
    end

    protected

    def client
      @client ||= ::Fog::Compute.new(:provider => "Libvirt", :libvirt_uri => url)
    end

    def hypervisor
      client.nodes.first
    end

  end
end
