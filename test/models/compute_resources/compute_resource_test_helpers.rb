module ComputeResourceTestHelpers
  def empty_servers
    servers = mock()
    servers.stubs(:get).returns(nil)
    servers
  end

  def servers_raising_exception(ex)
    servers = mock()
    servers.stubs(:get).raises(ex)
    servers
  end

  def mock_cr_servers(cr, servers)
    client = mock()
    client.stubs(:servers).returns(servers)

    cr.stubs(:client).returns(client)
    cr
  end

  def mock_cr(cr, attributes)
    attributes.each do |attr, stubbed_value|
      cr.stubs(attr).returns(stubbed_value)
    end
    cr
  end

  def assert_find_by_uuid_raises(ex_class, cr)
    assert_raises(ex_class) do
      cr.find_vm_by_uuid('abc')
    end
  end

  def assert_blank_attr_nilified(cr, attr_name)
    vm_attrs = {
      attr_name => '',
    }
    normalized = cr.normalize_vm_attrs(vm_attrs)

    assert(normalized.has_key?(attr_name))
    assert_nil(normalized[attr_name])
  end

  def assert_attrs_mapped(cr, attr_before, attr_after)
    vm_attrs = {
      attr_before => 'ATTR_VALUE',
    }
    normalized = cr.normalize_vm_attrs(vm_attrs)

    refute(normalized.has_key?(attr_before))
    assert_equal('ATTR_VALUE', normalized[attr_after])
  end

  def assert_blank_mapped_attr_nilified(cr, attr_before, attr_after)
    vm_attrs = {
      attr_before => '',
    }
    normalized = cr.normalize_vm_attrs(vm_attrs)

    refute(normalized.has_key?(attr_before))
    assert(normalized.has_key?(attr_after))
    assert_nil(normalized[attr_after])
  end

  def allowed_vm_attr_names
    @allowed_vm_attr_names ||= %w(
      add_cdrom
      annotation
      availability_zone
      boot_from_volume
      boot_volume_size
      cluster_id
      cluster_name
      cores
      cores_per_socket
      cpu_hot_add_enabled
      cpus
      associate_external_ip
      firmware
      flavor_id
      flavor_name
      floating_ip_network
      folder_name
      folder_path
      guest_id
      guest_name
      hardware_version_id
      hardware_version_name
      image_id
      image_name
      interfaces_attributes
      keys
      machine_type
      managed_ip
      memory
      memory_hot_add_enabled
      network
      resource_pool_id
      resource_pool_name
      scheduler_hint_filter
      scsi_controllers
      security_groups
      security_group_id
      security_group_name
      subnet_id
      subnet_name
      template_id
      template_name
      tenant_id
      tenant_name
      volumes_attributes
    )
  end

  def check_vm_attribute_names(cr)
    normalized_keys = cr.normalize_vm_attrs({}).keys

    normalized_keys.each do |name|
      assert(name == name.to_s.underscore, "Attribute '#{name}' breaks naming conventions. All attributes should be in snake_case.")
    end

    unexpected_names = normalized_keys - (normalized_keys & allowed_vm_attr_names)
    msg = "Some unexpected attributes detected: #{unexpected_names.join(', ')}."
    msg += "\nMake user you can't use one of names that already exist. If not, please extend ComputeResourceTestHelpers.allowed_vm_attr_names."
    assert(unexpected_names.empty?, msg)
  end
end
