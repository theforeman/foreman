module SSO
  METHODS = [Apache, Basic, Jwt, Oauth, OpenidConnect]

  def self.get_available(controller)
    all_methods = all.map { |method| method.new(controller) }
    all_methods.find(&:available?)
  end

  def self.all
    METHODS + (@registered_methods || [])
  end

  def self.register_method(klass)
    @registered_methods ||= []
    @registered_methods << klass
    klass
  end

  def self.deregister_method(klass)
    @registered_methods&.delete(klass)
  end
end
