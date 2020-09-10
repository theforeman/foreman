require 'test_helper'

class PxeLoaderSuggestionTest < ActiveSupport::TestCase
  context 'host' do
    def setup
      @host = FactoryBot.create(:host)
      @os = FactoryBot.create(:operatingsystem)
      Operatingsystem.any_instance.stubs(:preferred_loader).returns('PXELinux UEFI')
    end

    test 'host does not suggest PXEloader when OS is not set' do
      @host.suggest_default_pxe_loader
      assert_nil @host.pxe_loader
    end

    test 'host suggests default PXEloader for OS' do
      @host.operatingsystem = @os
      @host.suggest_default_pxe_loader
      assert_equal 'PXELinux UEFI', @host.pxe_loader
    end
  end

  context 'host with os param' do
    def setup
      @os = FactoryBot.create(:operatingsystem)
      @os.os_parameters.create!(:name => "pxe-loader", :value => "PXELinux A")
      @host = FactoryBot.create(:host, operatingsystem: @os)
    end

    test 'host suggests default PXEloader for OS' do
      @host.suggest_default_pxe_loader
      assert_equal 'PXELinux A', @host.pxe_loader
    end
  end

  context 'host with model param' do
    def setup
      @host = FactoryBot.create(:host)
      @os = FactoryBot.create(:operatingsystem)
      @os.os_parameters.create!(:name => "pxe-loader", :value => "PXELinux A")
    end

    test 'host suggests default PXEloader for OS' do
      @host.operatingsystem = @os
      @host.suggest_default_pxe_loader
      assert_equal 'PXELinux A', @host.pxe_loader
    end
  end

  context 'hostgroup' do
    def setup
      @hostgroup = FactoryBot.create(:hostgroup)
      @os = FactoryBot.create(:operatingsystem)
      Operatingsystem.any_instance.stubs(:preferred_loader).returns('PXELinux UEFI')
    end

    test 'hostgroup does not suggest PXEloader when OS is not set' do
      @hostgroup.suggest_default_pxe_loader
      assert_nil @hostgroup.pxe_loader
    end

    test 'hostgroup suggests default PXEloader for OS' do
      @hostgroup.operatingsystem = @os
      @hostgroup.suggest_default_pxe_loader
      assert_equal 'PXELinux UEFI', @hostgroup.pxe_loader
    end

    test 'hostgroup suggests default PXEloader for Parent OS' do
      parent = FactoryBot.create(:hostgroup, :operatingsystem => @os)
      @hostgroup.update_attribute(:parent_id, parent.id)
      @hostgroup.suggest_default_pxe_loader
      assert_equal 'PXELinux UEFI', @hostgroup.pxe_loader
    end
  end
end
