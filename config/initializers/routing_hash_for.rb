module ActionController
  module Routing
    class RouteSet
      class NamedRouteCollection
        def define_url_helper(route, name, options)
          helper = UrlHelper.create(route, options.dup)

          @module.remove_possible_method name
          @module.module_eval do
            define_method(name) do |*args|
              helper.call self, args
            end

            #because we heavily rely on the removed hash_for method in routes, we must add this monkey patch.
            define_method("hash_for_#{name}") do |*args|
              helper.send(:handle_positional_args, self, args, options, [])
            end
          end

          helpers << name
        end
      end
    end
  end
end