=begin
this initializer was added because gems like bootstrap-sass and patternfly-sass started adding their assets by
using initializers, having our plugins register only after: finisher_hook delays those gem's initializers
and as a result sprockets doesn't recognize their assets, we need to change all of our plugins to register
before: finisher_hook.
=end
plugins = Rails.application.railties.select { |e| e.railtie_name.match /foreman/ }
plugins.map(&:initializers).flatten.each do |initializer|
  options = initializer.instance_variable_get('@options')

  if options.key(:finisher_hook).present? && options.key(:finisher_hook) == :after
    deprecation_message = "\nInitializing plugins using :after => :finish_hook in\
your engine is deprecated. It delays the load of some assets in Sprockets.\n
Please change your plugin engine initializer to use :before =>\
:finisher_hook or after_initialize."
    Foreman::Deprecation.deprecation_warning('1.13', deprecation_message)
    options[:before] = options.delete :after
    initializer.instance_variable_set('@options', options)
  end
end