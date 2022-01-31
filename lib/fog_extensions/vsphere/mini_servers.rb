require 'fog_extensions/vsphere/mini_server'

module FogExtensions
  module Vsphere
    class MiniServers
      def initialize(client, dc, templates: false)
        @client     = client
        @dc         = client.send(:find_datacenters, dc).first
        @connection = client.send(:connection)
        @templates  = templates
      end

      def all(filters = { })
        property_collector = connection.serviceContent.propertyCollector

        results = property_collector.RetrieveProperties(:specSet => [filter_spec])

        folders = results.select { |result| result.obj.is_a?(RbVmomi::VIM::Folder) }

        folder_inventory = generate_folder_inventory(folders)

        vms = results.select { |result| result.obj.is_a?(RbVmomi::VIM::VirtualMachine) && result['config.template'] == templates && result['config.instanceUuid'].present? }

        vms.map do |vm|
          attrs = attribute_mapping.map do |key, value|
            [key, vm[value]]
          end.to_h

          attrs[:path] = folder_inventory[vm['parent']._ref][:path]

          MiniServer.new(attrs)
        end
      end

      private

      def generate_folder_inventory(folders)
        folder_inventory = folders.each_with_object({}) do |folder, inventory|
          parent = if folder['parent'] == dc
                     nil
                   else
                     folder['parent']._ref
                   end
          inventory[folder.obj._ref] = {
            :name => folder['name'],
            :parent => parent,
          }
        end
        set_folder_paths(folder_inventory)
        folder_inventory
      end

      def set_folder_paths(folder_inventory)
        folder_inventory.each do |ref, props|
          props[:path] = lookup_parent_folders(folder_inventory, ref).reverse.join('/')
        end
      end

      def lookup_parent_folders(folder_inventory, ref)
        return [] if folder_inventory[ref][:parent].nil?
        [folder_inventory[ref][:name], lookup_parent_folders(folder_inventory, folder_inventory[ref][:parent])].flatten
      end

      def filter_spec
        RbVmomi::VIM.PropertyFilterSpec(
          :objectSet => [
            :obj => dc.vmFolder,
            :skip => false,
            :selectSet => [
              RbVmomi::VIM.TraversalSpec(
                :name => 'tsFolder',
                :type => 'Folder',
                :path => 'childEntity',
                :skip => false,
                :selectSet => [
                  RbVmomi::VIM.SelectionSpec(:name => 'tsFolder'),
                ]
              ),
            ],
          ],
          :propSet => [
            { :type => 'Folder', :pathSet => ['name', 'parent'] },
            { :type => 'VirtualMachine', :pathSet => attribute_mapping.values + ['parent'] },
          ]
        )
      end

      def attribute_mapping
        {
          :name => 'name',
          :template => 'config.template',
          :identity => 'config.instanceUuid',
          :cpus => 'config.hardware.numCPU',
          :corespersocket => 'config.hardware.numCoresPerSocket',
          :memory => 'config.hardware.memoryMB',
          :state => 'runtime.powerState',
          :operatingsystem => 'config.guestFullName',
          :hypervisor => 'runtime.host',
        }
      end

      attr_reader :client, :connection, :dc, :templates
    end
  end
end
