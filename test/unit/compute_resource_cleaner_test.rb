require 'test_helper'

# Test suite for ComputeResourceCleaner without  initializing Rails' STI
# This test suite is designed to ensure that the ComputeResourceCleaner behaves correctly
# when cleaning up compute resources, hosts, hostgroups, compute attributes, and images.
class ComputeResourceCleanerTest < ActiveSupport::TestCase
  let(:klass) { 'Foreman::Model::Ovirt' }
  let(:cr_id) { setup_compute_resource }
  let(:subject) { ComputeResourceCleaner.new(klass: klass) }

  setup do
    setup_compute_attrs
    setup_image
    setup_hostgroup
    setup_host

    Rails.logger.stubs(:info)
  end

  test 'simulate logs affected resources' do
    Rails.logger.expects(:info).with(regexp_matches(/simulation mode/))
    Rails.logger.expects(:info).with(regexp_matches(/Compute resources ids to remove/))
    Rails.logger.expects(:info).with(regexp_matches(/Updating Host ids/))
    Rails.logger.expects(:info).with(regexp_matches(/Updating Hostgroup ids/))
    Rails.logger.expects(:info).with(regexp_matches(/Removing ComputeAttribute ids/))
    Rails.logger.expects(:info).with(regexp_matches(/Removing Image ids/))
    subject.simulate
  end

  test 'simulate does not change the resources' do
    original_host_count = Host.where(compute_resource_id: cr_id).count
    original_hostgroup_count = Hostgroup.where(compute_resource_id: cr_id).count
    original_compute_attribute_count = ComputeAttribute.count
    original_image_count = Image.count

    subject.simulate

    assert_equal original_host_count, Host.where(compute_resource_id: cr_id).count
    assert_equal original_hostgroup_count, Hostgroup.where(compute_resource_id: cr_id).count
    assert_equal original_compute_attribute_count, ComputeAttribute.count
    assert_equal original_image_count, Image.count
  end

  test 'run!' do
    subject.run!

    assert_empty Host.where(compute_resource_id: cr_id)
    assert_empty Hostgroup.where(compute_resource_id: cr_id)
    assert_empty ComputeAttribute.where(compute_resource_id: cr_id)
    assert_empty Image.where(compute_resource_id: cr_id)
    assert_empty ComputeResource.where(type: klass)
  end

  test 'run! updates hosts' do
    host_id = Host.where(compute_resource_id: cr_id).pick(:id)
    subject.run!

    host = Host.find(host_id)
    assert_nil host.compute_resource_id
    assert_nil host.compute_profile_id
    assert_nil host.uuid
    assert_nil host.image_id
  end

  test 'run! updates hostgroups' do
    hg_id = Hostgroup.where(compute_resource_id: cr_id).pick(:id)
    subject.run!

    hostgroup = Hostgroup.find(hg_id)
    assert_nil hostgroup.compute_resource_id
    assert_nil hostgroup.compute_profile_id
  end

  private

  # Create a compute resource without initializing Rail's STI
  def setup_compute_resource
    ActiveRecord::Base.connection.execute <<~SQL
      INSERT INTO compute_resources (type, name, created_at, updated_at)
      VALUES ('#{klass}', 'ovirt_#{Time.now.to_i}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
    SQL

    ComputeResource.where(type: klass).pick(:id)
  end

  def setup_compute_attrs
    attrs = FactoryBot.create(:compute_attribute, compute_resource: compute_resources(:one))
    attrs.update(compute_resource_id: cr_id)
  end

  def setup_image
    image = FactoryBot.create(:image, compute_resource: compute_resources(:one))
    Image.where(id: image.id).update_all(compute_resource_id: cr_id)
  end

  def setup_hostgroup
    Hostgroup.create(name: "crtest#{Time.now.to_i}", compute_resource_id: cr_id, compute_profile: compute_profiles(:one))
  end

  def setup_host
    host = Host.create(managed: false, name: "crtest#{Time.now.to_i}", compute_profile_id: compute_profiles(:one), uuid: Time.now.to_i)
    Host.where(id: host.id).update_all(compute_resource_id: cr_id)
  end
end
