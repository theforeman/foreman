require 'test_helper'

class SolarisTest < ActiveSupport::TestCase
  setup { disable_orchestration }

  test "jumpstart parameter generation" do
    h = FactoryBot.create(:host, :managed, :with_environment, :domain => domains(:yourdomain),
          :interfaces => [FactoryBot.build(:nic_primary_and_provision,
            :ip => '2.3.4.10')],
          :architecture => architectures(:sparc),
          :operatingsystem => operatingsystems(:solaris10),
          :pxe_loader => '',
          :compute_resource => compute_resources(:one),
          :model => models(:V210),
          :medium => media(:solaris10),
          :puppet_proxy => smart_proxies(:puppetmaster),
          :ptable => FactoryBot.create(:ptable, :operatingsystem_ids => [operatingsystems(:solaris10).id])
    )
    Resolv::DNS.any_instance.stubs(:getaddress).with("brsla01").returns("2.3.4.5").once
    Resolv::DNS.any_instance.stubs(:getaddress).with("brsla01.yourdomain.net").returns("2.3.4.5").once
    result = h.os.jumpstart_params h, h.model.vendor_class
    assert_equal({
                   :vendor => "<Sun-Fire-V210>",
                   :install_path => "/vol/solgi_5.10/sol10_hw0910_sparc",
                   :install_server_ip => "2.3.4.5",
                   :install_server_name => "brsla01",
                   :jumpstart_server_path => "2.3.4.5:/vol/jumpstart",
                   :root_path_name => "/vol/solgi_5.10/sol10_hw0910_sparc/Solaris_10/Tools/Boot",
                   :root_server_hostname => "brsla01",
                   :root_server_ip => "2.3.4.5",
                   :sysid_server_path => "2.3.4.5:/vol/jumpstart/sysidcfg/sysidcfg_primary",
                 }, result)
  end
end
