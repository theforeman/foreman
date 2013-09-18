require 'fog_extensions/vsphere/mini_server'

module FogExtensions
  module Vsphere
    class MiniServers

      def initialize client, dc
        @client = client
        @dc     = client.send(:find_datacenters, dc)[0]
      end

      def all(filters = { })
        ret = []
        allbyfolder(dc.vmFolder, nil).each do |entry|
          ret.push MiniServer.new(entry[:vm], entry[:path])
        end
        ret
      end

      def allbyfolder(folder, path = nil, recursing = false)
        ret = []
        if recursing
          path = path.nil? ? folder.name : path + '/' + folder.name
        end
        folder.childEntity.each do |entity|
          if entity.is_a?(RbVmomi::VIM::Folder)
            ret = ret + (allbyfolder(entity, path, true))
          elsif entity.is_a?(RbVmomi::VIM::VirtualMachine)
            ret.push ({ :vm => entity, :path => path })
          end
        end
        ret
      end
        
      private
      attr_reader :client, :dc
    end
  end
end
