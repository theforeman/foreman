require 'test_helper'

module FogExtensions
  module Vsphere
    class ServerTest < ActiveSupport::TestCase
      setup { Fog.mock! }
      teardown { Fog.unmock! }

      describe '#select_nic' do
        let(:uuid) { '5032c8a5-9c5e-ba7a-3804-832a03e16381' }
        let(:client) do
          ::Fog::Compute.new(
            :provider                     => 'vsphere',
            :vsphere_username             => 'someuser',
            :vsphere_password             => 'password',
            :vsphere_server               => 'vsphere.example.com',
            :vsphere_expected_pubkey_hash => 'somehash'
          )
        end
        let(:vm) { client.servers.get(uuid) }
        let(:fog_nics) { vm.interfaces.dup }
        let(:host) { FactoryBot.build(:host, :managed) }

        setup do
          vm.service.stubs(:list_networks).returns(
            [
              {
                :name => 'exampledvnet',
                :accessible => true,
                :id => 'dvportgroup-123456',
                :vlanid => 123,
                :virtualswitch => 'VDS-example',
                :datacenter => 'Solutions',
                :_ref => 'dvportgroup-123456',
              },
              {
                :name => 'examplenet',
                :accessible => true,
                :id => 'network-12345',
                :datacenter => 'Solutions',
                :_ref => 'network-12345',
              },
            ]
          )
        end

        context 'on a standard switch' do
          let(:nic) do
            host.primary_interface.tap do |nic|
              nic.compute_attributes = {
                'type' => 'VirtualVmxnet3',
                'network' => 'examplenet',
              }
            end
          end

          test 'finds the vm nic for a host nic' do
            fog_nic = vm.interfaces.first
            fog_nic.network = 'examplenet'
            assert_equal vm.interfaces.first, vm.select_nic(fog_nics, nic)
          end
        end

        context 'on a distributed switch' do
          let(:nic) do
            host.primary_interface.tap do |nic|
              nic.compute_attributes = {
                'type' => 'VirtualVmxnet3',
                'network' => 'dvportgroup-123456',
              }
            end
          end

          test 'finds the vm nic for a host nic' do
            fog_nic = vm.interfaces.first
            fog_nic.network = 'dvportgroup-123456'
            assert_equal vm.interfaces.first, vm.select_nic(fog_nics, nic)
          end
        end
      end
    end
  end
end
