require 'fog_extensions/vsphere/mini_server'

module FogExtensions
  module Vsphere
    class MiniServers

      def initialize(client, dc)
        @client = client
        @dc     = client.send(:find_datacenters, dc)[0]
      end

      def all(filters = { })
        allvmsbyfolder(dc.vmFolder, nil).map do |entry|
          MiniServer.new(entry[:vm], entry[:path], entry[:uuid])
        end
      end

      def allvmsbyfolder(folder, path = nil)
        ret = []
        unless folder == @dc.vmFolder
          path = path.nil? ? folder.name : path + '/' + folder.name
        end
        folder.childEntity.each do |entity|
          if entity.is_a?(RbVmomi::VIM::Folder)
            ret.push(*allvmsbyfolder(entity, path))
          elsif entity.is_a?(RbVmomi::VIM::VirtualMachine)
            config = entity.config
            if (config && !config.template && (uuid = config.instanceUuid))
              ret.push({ :vm => entity, :path => path, :uuid => uuid})
            end
          end
        end
        ret
      end

      private
      attr_reader :client, :dc
    end
  end
end
