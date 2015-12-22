# Gems like bootstrap-sass and patternfly-sass started adding their assets by
# using initializers. Since our plugins register only after: finisher_hook, that
# delays the assets initializers and they run after Sprockets::Context is
# instantiated. As a result sprockets doesn't recognize these assets. A fix for
# this is to to make our plugins to register before: finisher_hook.
#
# See https://github.com/theforeman/foreman/pull/2943#issuecomment-168039237 for
# more details
plugins = Rails.application.railties.select { |e| e.railtie_name.match /foreman/ }
plugins.map(&:initializers).flatten.each do |initializer|
  options = initializer.instance_variable_get('@options')

  if options.key(:finisher_hook).present? && options.key(:finisher_hook) == :after
    deprecation_message = "\nInitializing plugins using :after => :finish_hook in\
your engine is deprecated. It delays the load of some assets in Sprockets. \
If you are the plugin author, please change your plugin engine initializer to use\
:before => :finisher_hook or after_initialize."
    Foreman::Deprecation.deprecation_warning('1.13', deprecation_message)
    options[:before] = options.delete :after
    initializer.instance_variable_set('@options', options)
  end
end
