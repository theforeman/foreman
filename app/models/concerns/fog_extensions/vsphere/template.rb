module FogExtensions
  module Vsphere
    module Template
      extend ActiveSupport::Concern
      included do
        alias_method_chain :get_vm_by_name, :nested_template
      end

      def get_vm_by_name_with_nested_template(name, dc)
        # In fog v1.29.0 get_templates is broken when the template is in a folder.
        # A fix was merged into Fog https://github.com/fog/fog/commit/6f205bbe0cb9dd2fab3c6b0d371b9933aba41507
        # this method override should be removed when fog v.1.30.0 will be used in Foreman.
        vms = raw_list_all_virtual_machines(dc)

        if name.include?('/')
          folder, basename = name.split('/')
          vms.keep_if { |v| v["name"] == basename && v.parent["name"] == folder }.first
        else
          vms.keep_if { |v| v["name"] == name }.first
        end
      end
    end
  end
end
