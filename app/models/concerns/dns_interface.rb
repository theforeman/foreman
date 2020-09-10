module DnsInterface
  extend ActiveSupport::Concern

  RECORD_TYPES = [:a, :aaaa, :ptr4, :ptr6]

  def dns_record(type)
    validate_record_type(type)

    record = get_dns_record(type)
    return record if record.present?

    return unless dns_feasible?(type)

    handle_validation_errors do
      store_dns_record(type,
        dns_class(type).new(send(:"dns_#{type}_record_attrs")))
    end
  end

  protected

  def dns_feasible?(type)
    validate_record_type(type)

    case type
    when :a
      dns?
    when :aaaa
      dns6?
    when :ptr6
      reverse_dns6?
    when :ptr4
      reverse_dns?
    end
  end

  def recreate_dns_record(type)
    return true if dns_record(type).nil? || dns_record(type).valid?
    set_dns_record(type)
  end

  def set_dns_record(type)
    dns_record(type).create
  end

  def set_conflicting_dns_record(type)
    dns_record(type).conflicts.each { |c| c.create }
  end

  def del_dns_record(type)
    dns_record(type).destroy
  end

  def del_conflicting_dns_record(type)
    dns_record(type).conflicts.each { |c| c.destroy }
  end

  def del_dns_record_safe(type)
    return unless dns_record(type).present?
    del_dns_record(type)
  rescue => e
    Foreman::Logging.exception "Proxy failed to delete DNS #{type}_record for #{name} (#{ip}/#{ip6})", e, :level => :error
  end

  private

  def dns_class(type)
    validate_record_type(type)
    "Net::DNS::#{type.upcase}Record".constantize
  end

  def get_dns_record(type)
    instance_variable_get("@dns_#{type}_record")
  end

  def store_dns_record(type, value)
    instance_variable_set("@dns_#{type}_record", value)
  end

  def validate_record_type(type)
    raise ::Foreman::Exception.new(N_("%s is not a valid DNS record type"), type) unless RECORD_TYPES.include?(type)
  end

  def dns_a_record_attrs
    { :hostname => hostname, :ip => ip, :resolver => domain.resolver, :proxy => domain.proxy }
  end

  def dns_aaaa_record_attrs
    { :hostname => hostname, :ip => ip6, :resolver => domain.resolver, :proxy => domain.proxy }
  end

  def dns_ptr4_record_attrs
    { :hostname => hostname, :ip => ip, :proxy => subnet.dns_proxy }
  end

  def dns_ptr6_record_attrs
    { :hostname => hostname, :ip => ip6, :proxy => subnet6.dns_proxy }
  end
end
