require 'test_helper'

class Types::ComputeAttributeTypeTest < ActiveSupport::TestCase
  test 'vmAttrs resolve function' do
    vm_attrs_hash = {
      cpus: 4,
      memory: 536_870_912,
      volumes_attributes: {
        '0' => { :vol => 1 },
        '1' => { :vol => 2 }
      }
    }
    compute_attribute = ComputeAttribute.new(vm_attrs: vm_attrs_hash)

    vm_attrs_field = ForemanGraphqlSchema.types['ComputeAttribute'].fields['vmAttrs']

    resolved_vm_attrs = vm_attrs_field.resolve(compute_attribute, nil, nil)

    expected_vm_attrs = {
      'cpus' => '4',
      'memory' => '536870912',
      'volumes_attributes' => vm_attrs_hash[:volumes_attributes]
    }

    assert_equal resolved_vm_attrs, expected_vm_attrs
  end
end
