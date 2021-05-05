require 'test_helper'

module Katello
  class RhsmFactParserTest < ActiveSupport::TestCase
    def setup
      @facts = {
        'net.interface.bond0.mac_address' => '52:54:00:6D:40:72',
        'net.interface.eth0.mac_address' => '00:00:00:00:00:12',
        'net.interface.eth0.ipv4_address' => '192.168.0.1',
        'net.interface.eth0.1.mac_address' => '00:00:00:00:00:12',
        'net.interface.eth0.1.ipv4_address' => '192.168.0.2',
        'net.interface.eth1.permanent_mac_address' => '52:54:00:6D:40:72',
        'net.interface.ethnone.mac_address' => 'none',
        'net.interface.eth2.mac_address' => '00:00:00:00:00:13',
        'net.interface.eth2.permanent_mac_address' => '52:54:00:D8:27:F7',
        'net.interface.eth3.ipv4_address' => 'Unknown',
        'net.interface.eth3.mac_address' => '00:00:00:00:00:14',
      }
    end
    let(:parser) { RhsmFactParser.new(@facts) }

    def test_virtual_interfaces
      assert parser.interfaces['eth0.1'][:virtual]
      refute parser.interfaces['eth0'][:virtual]
    end

    def test_get_interfaces
      interfaces = parser.get_interfaces
      assert_includes interfaces, 'eth0'
      refute_includes interfaces, 'ethnone'
      assert_includes interfaces, 'eth2'
    end

    def test_get_facts_for_interface_with_ip
      expected_eth0 = {
        'link' => true,
        'macaddress' => @facts['net.interface.eth0.mac_address'],
        'ipaddress' => @facts['net.interface.eth0.ipv4_address'],
      }
      assert_equal expected_eth0, parser.get_facts_for_interface('eth0')
    end

    def test_get_facts_for_interface_without_ip
      expected_eth2 = {
        'link' => true,
        'macaddress' => @facts['net.interface.eth2.permanent_mac_address'],
        'ipaddress' => nil,
      }
      assert_equal expected_eth2, parser.get_facts_for_interface('eth2')
    end

    def test_get_facts_for_bonded_interface
      # if an interface is part of a bond, it should report the physical mac and not the bond's mac
      expected_mac_address = @facts['net.interface.eth2.permanent_mac_address']
      actual_mac_address = parser.get_facts_for_interface('eth2')['macaddress']

      assert_equal actual_mac_address, expected_mac_address
      assert_not_equal actual_mac_address, @facts['net.interface.eth2.mac_address']
    end

    def test_get_facts_for_interface_with_invalid_ip
      assert_equal @facts['net.interface.eth3.mac_address'], parser.get_facts_for_interface('eth3')['macaddress']
      assert_empty parser.get_facts_for_interface('eth3')['ipaddress']
    end

    def test_valid_centos_os
      @facts['distribution.name'] = 'CentOS'
      @facts['distribution.version'] = '7.2'

      assert parser.operatingsystem.is_a?(::Operatingsystem)
    end

    def test_invalid_centos_os
      @facts['ignore_os'] = true
      @facts['distribution.name'] = 'CentOS'
      @facts['distribution.version'] = '7'

      refute parser.operatingsystem
    end

    def test_operatingsystem_oel
      @facts['distribution.name'] = 'Oracle Linux Server'
      @facts['distribution.version'] = '7.7'
      @facts['distribution.id'] = '7.7'

      os = parser.operatingsystem

      assert_equal os.name, 'OracleLinux'
      assert_equal os.title, 'OracleLinux 7.7'
      assert_nil os.release_name
    end

    def test_operatingsystem_rockylinux
      @facts['distribution.name'] = 'Rocky Linux'
      @facts['distribution.version'] = '8.3'

      assert_equal parser.operatingsystem.name, 'Rocky'
      assert_equal parser.operatingsystem.major, '8'
      assert_equal parser.operatingsystem.minor, '3'
    end

    def test_operatingsystem_debian
      @facts['distribution.name'] = 'Debian GNU/Linux'
      @facts['distribution.version'] = '9'
      @facts['distribution.id'] = 'stretch'

      assert_equal parser.operatingsystem.release_name, 'stretch'
      assert_equal parser.operatingsystem.name, 'Debian'
      assert_equal parser.operatingsystem.type, 'Debian'
    end

    def test_operatingsystem_ubuntu
      @facts['distribution.name'] = 'Ubuntu GNU/Linux'
      @facts['distribution.version'] = '19.04'
      @facts['distribution.id'] = 'Disco Dingo'

      assert_equal parser.operatingsystem.release_name, 'disco'
      assert_equal parser.operatingsystem.name, 'Ubuntu'
      assert_equal parser.operatingsystem.type, 'Debian'
      assert_equal parser.operatingsystem.major, '19'
      assert_equal parser.operatingsystem.minor, '04'
    end

    def test_operatingsystem_release
      existing_os = FactoryBot.create(:operatingsystem, name: 'CentOS', major: '7', release_name: 'Core')
      @facts['distribution.name'] = 'CentOS'
      @facts['distribution.version'] = '7'

      assert_equal existing_os.id, parser.operatingsystem.id
    end

    def test_operatingsystem_rhel_workstation
      @facts['distribution.name'] = 'Red Hat Enterprise Linux Workstation'
      @facts['distribution.version'] = '7.7'
      @facts['distribution.id'] = 'Maipo'

      assert_equal parser.operatingsystem.name, 'RedHat_Workstation'
      assert_equal parser.operatingsystem.type, 'Redhat'
      assert_equal parser.operatingsystem.major, '7'
      assert_equal parser.operatingsystem.minor, '7'
    end

    def test_operatingsystem_rhel_server
      @facts['distribution.name'] = 'Red Hat Enterprise Linux Server'
      @facts['distribution.version'] = '7.7'
      @facts['distribution.id'] = 'Maipo'

      assert_equal parser.operatingsystem.name, 'RedHat'
      assert_equal parser.operatingsystem.type, 'Redhat'
      assert_equal parser.operatingsystem.major, '7'
      assert_equal parser.operatingsystem.minor, '7'
    end

    def test_operatingsystem_almalinux
      @facts['distribution.name'] = 'AlmaLinux'
      @facts['distribution.version'] = '8.3'
      @facts['distribution.id'] = 'Purple Manul'

      assert_equal parser.operatingsystem.name, 'AlmaLinux'
      assert_equal parser.operatingsystem.type, 'Redhat'
      assert_equal parser.operatingsystem.major, '8'
      assert_equal parser.operatingsystem.minor, '3'
    end

    def test_operatingsystem_amazon
      @facts['distribution.name'] = 'Amazon'
      @facts['distribution.version'] = '2.2'
      @facts['distribution.id'] = 'Karoo'

      assert_equal parser.operatingsystem.name, 'Amazon'
      assert_equal parser.operatingsystem.major, '2'
      assert_equal parser.operatingsystem.minor, '2'
    end

    def test_uname_architecture
      @facts['uname.machine'] = 'i686'

      assert 'i386', parser.architecture.name
    end
  end
end
