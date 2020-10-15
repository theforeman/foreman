require 'test_helper'

class ComputeAttributeTest < ActiveSupport::TestCase
  setup do
    Fog.mock!
    User.current = users :admin
  end

  teardown do
    Fog.unmock!
  end

  let(:compute_profile) { FactoryBot.create(:compute_profile) }
  let(:compute_resource) { FactoryBot.create(:compute_resource, :libvirt) }
  let(:basic_vm_attrs) { { 'flavor_id' => 'm1.small', 'availability_zone' => 'eu-west-1a' } }
  let(:vm_attrs) { basic_vm_attrs }
  let(:compute_attribute) { FactoryBot.create(:compute_attribute, compute_profile: compute_profile, compute_resource: compute_resource, vm_attrs: vm_attrs) }

  should validate_uniqueness_of(:compute_profile_id).
    scoped_to(:compute_resource_id)
  should validate_uniqueness_of(:compute_resource_id).
    scoped_to(:compute_profile_id)

  test "getter attributes in vm_attrs hash" do
    assert_equal 'm1.small', compute_attribute.flavor_id
    assert_equal 'eu-west-1a', compute_attribute.availability_zone
  end

  test "raise error for nonexistant getter attribute in vm_attrs hash" do
    assert_raise Foreman::Exception do
      compute_attribute.nonexistant_flavor_field
    end
  end

  test "#provider_friendly_name" do
    refute_nil compute_attribute.provider_friendly_name
    assert_equal(compute_resource.provider_friendly_name, compute_attribute.provider_friendly_name)
  end

  describe "vm_interfaces" do
    let(:vm_attrs) { basic_vm_attrs.merge("#{compute_resource.interfaces_attrs_name}_attributes" => nics_attributes) }
    let(:expected_vm_interfaces) { [{'attr' => 1}, {'attr' => 2}] }

    context 'without nics_attributes' do
      let(:vm_attrs) { basic_vm_attrs }

      test "returns empty array if interface attributes are missing" do
        assert_empty compute_attribute.vm_interfaces
      end
    end

    context 'with hash attributes' do
      let(:nics_attributes) { { '1' => { 'attr' => 1 }, '2' => { 'attr' => 2 } } }

      test 'returns array of interface attributes' do
        assert_equal expected_vm_interfaces, compute_attribute.vm_interfaces
      end
    end

    context 'with array attributes' do
      let(:nics_attributes) { [{ 'attr' => 1 }, { 'attr' => 2 }] }

      test 'returns array of interface attributes' do
        assert_equal expected_vm_interfaces, compute_attribute.vm_interfaces
      end
    end
  end
end
