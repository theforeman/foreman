module ActionDispatch
  module Routing
    class RouteSet
      class NamedRouteCollection
        def define_url_helper(mod, route, name, opts, route_key, url_strategy)
          helper = UrlHelper.create(route, opts, route_key, url_strategy)
          mod.module_eval do
            define_method(name) do |*args|
              options = nil
              options = args.pop if args.last.is_a? Hash
              helper.call self, args, options
            end

            # because we heavily rely on the removed hash_for method in routes, we must add this monkey patch.
            define_method("hash_for_#{name}") do |*args|
              inner_options = nil
              inner_options = args.pop if args.last.is_a? Hash
              helper.send(:handle_positional_args,
                {},
                inner_options || {},
                args,
                opts.merge(:use_route => route_key),
                route.segment_keys.uniq)
            end
          end
        end
      end
    end
  end
end
