begin
  require 'fog'
rescue LoadError
  Rails.logger.debug "Fog is not installed - unable to manage compute resources"
end

module Fog
  class Model

    attr_accessor :_delete

    def persisted?
      !!identity
    end

    def to_json(options={})
      ActiveSupport::JSON.encode(self, options)
    end

    def as_json(options = {})
      attr = attributes.dup
      attr.delete(:client)
      attr
    end

    def interfaces_attributes= attrs
      @interfaces_attributes = attrs
    end

    # libvirt call these nics, vs interfaces
    def nics_attributes= attrs
      @nics_attributes = attrs
    end

    def volumes_attributes= attrs
      @volumes_attributes = attrs
    end

  end

  require 'fog/libvirt/compute'
  require 'fog/libvirt/models/compute/server'
  module Compute
    class Libvirt

      class Server < Fog::Compute::Server
        # Libvirt expect units in KB, while we use bytes
        def memory
          attributes[:memory_size].to_i * 1024
        end

        def memory= mem
          attributes[:memory_size] = mem.to_i / 1024 if mem
        end

      end
    end
    class Ovirt

      class Volume < Fog::Model

        def as_json(options={})
          size_gb
          super options
        end

      end
    end
  end
end if defined? Fog
