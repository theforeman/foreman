class SubnetsConsistencyValidator < ActiveModel::Validator
  def validate(record)
    return unless record.subnet && record.subnet6
    validate_mtu(record)
    validate_vlanid(record)
  end

  def validate_mtu(record)
    return unless record.subnet.mtu != record.subnet6.mtu
    add_error(record, _('MTU is not consistent across subnets'))
  end

  def validate_vlanid(record)
    return unless record.subnet.vlanid != record.subnet6.vlanid
    add_error(record, _('VLAN ID is not consistent across subnets'))
  end

  def add_error(record, message)
    record.errors.add(:subnet_id, message)
    record.errors.add(:subnet6_id, message)
  end
end
