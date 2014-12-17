module StrongParametersHelper
  def permitted_attributes
    Foreman::PermittedAttributes
  end

  def foreman_params
    permitted_params = "permitted_#{controller_name.singularize}_attributes"
    raise Foreman::Exception.new(N_('Can not find parameter method')) unless self.respond_to?(permitted_params.to_sym)
    params.require(controller_name.singularize.to_sym).permit(*send(permitted_params))
  end

  delegate(*(Foreman::PermittedAttributes::ATTRIBUTES + [{:to => :permitted_attributes, :prefix => :permitted}]))

  def permitted_operatingsystem_attributes
    permitted_attributes.operatingsystem_attributes +
        [
          :os_parameters_attributes => permitted_os_parameters_attributes,
          :os_default_templates_attributes => permitted_os_default_templates_attributes
        ]
  end

  def permitted_user_attributes
    if editing_self?
      permitted_attributes.user_self_attributes
    else
      if User.current.admin?
        permitted_attributes.user_attributes + permitted_attributes.user_admin_attributes
      else
        permitted_attributes.user_attributes
      end
    end
  end

  def permitted_compute_attribute_attributes
    permitted_attributes.compute_attribute_attributes +
        [:vm_attrs => vm_attributes]
  end

  def permitted_config_template_attributes
    permitted_attributes.config_template_attributes +
        [:template_combinations_attributes => permitted_template_combinations_attributes]
  end

  def permitted_domain_attributes
    permitted_attributes.domain_attributes +
        [:domain_parameters_attributes => permitted_parameter_attributes]
  end

  def permitted_hostgroup_attributes
    permitted_attributes.hostgroup_attributes +
        [:group_parameters_attributes => permitted_parameter_attributes]
  end

  def permitted_host_attributes
    permitted_attributes.host_attributes +
        [
          :interfaces_attributes => [:type, :id, :_destroy, :mac, :identifier, :name, :domain_id, :subnet_id, :ip, :managed, :virtual, :tag, :physical_device, :password],
          :compute_attributes => vm_attributes,
          :lookup_values_attributes => [:lookup_key_id, :value, :_destroy, :id],
          :host_parameters_attributes => [:name, :value, :hidden_value, :_destroy, :nested, :id]
        ]
  end

  def permitted_puppetclass_attributes
    permitted_attributes.puppetclass_attributes +
        [
          :lookup_keys_attributes  => permitted_lookup_key_attributes,
          :class_params_attributes => permitted_class_params_attributes
        ]
  end

  def permitted_usergroup_attributes
    permitted_attributes.usergroup_attributes +
        [:external_usergroups_attributes => [:name, :auth_source_id] ]
  end

  def vm_attributes
    [
        ## case ComputeResource.type ??
        # Libvirt
      *(permitted_vm_attrs_libvirt_attributes +
      # EC2
      permitted_vm_attrs_ec2_attributes +
      # Google Cloud Engine
      permitted_vm_attrs_gce_attributes +
      # OpenStack
      permitted_vm_attrs_openstack_attributes +
      #oVirt
      permitted_vm_attrs_ovirt_attributes +
      #RackSpace
      permitted_vm_attrs_rackspace_attributes +
      #vmware
      permitted_vm_attrs_vmware_attributes)
    ]
  end
end
