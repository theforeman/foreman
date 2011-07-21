require 'test_helper'

class DhcpOrchestrationTest < ActiveSupport::TestCase
  def test_host_should_have_dhcp
    if unattended?
      h = hosts(:one)
      assert h.valid?
      assert h.dhcp != nil
      assert h.dhcp?
    end
  end

  def test_host_should_not_have_dhcp
    if unattended?
      h = hosts(:minimal)
      assert h.valid?
      assert_equal h.dhcp, nil
      assert_equal h.dhcp?, false
    end
  end

  test "jumpstart parameter generation" do
    h = hosts(:sol10host)
    Resolv::DNS.any_instance.stubs(:getaddress).with("brsla01").returns("2.3.4.5").once
    Resolv::DNS.any_instance.stubs(:getaddress).with("brsla01.yourdomain.net").returns("2.3.4.5").once
    #User.current = users(:admin)
    result = h.os.jumpstart_params h
    assert_equal result, {"<Sun-Fire-V210>install_path" => "/vol/solgi_5.10/sol10_hw0910_sparc",
                          "<Sun-Fire-V210>install_server_ip" => "2.3.4.5",
                          "<Sun-Fire-V210>install_server_name" => "brsla01",
                          "<Sun-Fire-V210>jumpstart_server_path" => "2.3.4.5:/vol/jumpstart",
                          "<Sun-Fire-V210>root_path_name" => "/vol/solgi_5.10/sol10_hw0910_sparc/Solaris_10/Tools/Boot",
                          "<Sun-Fire-V210>root_server_hostname" => "brsla01",
                          "<Sun-Fire-V210>root_server_ip" => "2.3.4.5",
                          "<Sun-Fire-V210>sysid_server_path" => "2.3.4.5:/vol/jumpstart/sysidcfg/sysidcfg_primary"
                          }
  end

end
