require 'test_helper'

class HypervisorTest < ActiveSupport::TestCase
  def test_should_be_valid

    name = "my kvm hypervisor"
    uri  = "qemu+ssh://mysystem/system"
    kind = "libvirt"
    assert Hypervisor.new(:name => name, :uri => uri, :kind => kind).valid?
  end
end
