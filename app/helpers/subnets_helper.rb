module SubnetsHelper
  # expand or minimize the subnet when importing
  def minimal?(subnets)
    subnets.each { |s| return false unless s.errors.empty? }
    subnets.size > 2
  end

  def subnet_type_f(f)
    field(f, :type, :label => _('Protocol'), :required => true) do
      subnet_types.collect do |text, value|
        radio_button_f(f, :type, subnet_type_data(value.constantize).merge({:value => value, :text => text, :disabled => (!f.object.new_record? || action_name == 'import')}))
      end.join(' ').html_safe
    end
  end

  private

  def subnet_types
    Subnet::SUBNET_TYPES.map do |klass, type_name|
      [_(type_name), klass.to_s]
    end
  end

  def subnet_type_data(klass)
    {
      'data-supported_ipam_modes' => klass.supported_ipam_modes_with_translations.to_json,
      'data-supports_dhcp' => klass.supports_ipam_mode?(:dhcp),
      'data-show_mask' => klass.show_mask?,
    }
  end

  def subnet_ipam_modes(type)
    return [] unless Subnet::SUBNET_TYPES.key?(type.to_sym)
    type.safe_constantize.supported_ipam_modes_with_translations
  end

  def external_ipam?(subnet)
    subnet&.ipam == IPAM::MODES[:external_ipam]
  end
end
