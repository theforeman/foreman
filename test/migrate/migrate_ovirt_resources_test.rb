require 'test_helper'
require Rails.root.join('db/migrate/20250414121956_migrate_ovirt_resources.rb') # adjust the timestamp

class MigrateOvirtResourcesTest < ActiveSupport::TestCase
  let(:migration) { MigrateOvirtResources.new }
  let(:cr) { ComputeResource.new(name: 'ovirt-test', url: 'http://ovirt.example.com', type: 'Foreman::Model::Ovirt', user: "test", password: "changeme") }
  let(:host) { Host.new(name: "test#{Time.now.to_i}", ip: "192.168.0.23", compute_resource_id: cr.id, managed: false) }

  setup do
    ComputeResource.inheritance_column = :_disabled

    cr.save(validate: false)
    host.save(validate: false)
    @hostgroup = FactoryBot.create(:hostgroup, compute_resource: cr)
  end

  teardown do
    ComputeResource.inheritance_column = :type
  end

  test "removes oVirt compute resources and related data" do
    assert_not_empty Hostgroup.where(compute_resource_id: cr.id)
    assert_not_empty Host.where(compute_resource_id: cr.id)

    assert_difference('ComputeResource.count', -1) do
      MigrateOvirtResources.new.up
    end

    assert_empty Hostgroup.where(compute_resource_id: cr.id)
    assert_empty Host.where(compute_resource_id: cr.id)
  end
end
