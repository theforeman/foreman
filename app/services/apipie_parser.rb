Apipie.reload_documentation if Apipie.configuration.reload_controllers?

class ApipieParser

  delegate :logger, :to => :Rails

  def self.method_descriptions(controller, version = Apipie.configuration.default_version)
    Apipie.app.resource_descriptions[version][controller].method_descriptions
  end

  def self.allowed_params(controller, action, version = Apipie.configuration.default_version)
    attributes = []
    a = self.method_descriptions(controller).detect { |md| md.method.to_s == action.to_s }
    a.params_ordered.each do |b|
      if b.validator.try(:params_ordered)
        attributes = b.validator.params_ordered.map(&:name)
      end
    end if a
    attributes
  end

end
