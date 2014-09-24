Apipie.reload_documentation if Apipie.configuration.reload_controllers?

class ApipieParser

  delegate :logger, :to => :Rails

  def self.allowed_params(controller, action, version = Apipie.configuration.default_version)
     attributes = []
     a = Apipie.to_json(version, controller, action)
     a[:docs][:resources][0][:methods][0][:params].each do |b|
       attributes = b[:params].map{|a| a[:name]} if b[:params]
     end
     attributes
  end

end
