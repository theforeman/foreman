module FogExtensions
  module Vsphere
    module Folder
      def to_label
        if parent and parent != datacenter
          "#{parent} / #{name}"
        else
          name == "vm" ? "VM Folder" : name
        end
      end
    end

  end
end
