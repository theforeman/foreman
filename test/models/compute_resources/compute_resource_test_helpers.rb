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

  def assert_find_by_uuid_raises(ex_class, cr)
    assert_raises(ex_class) do
      cr.find_vm_by_uuid('abc')
    end
  end
end
