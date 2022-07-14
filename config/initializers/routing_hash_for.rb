module ActionDispatch
  module Routing
    class RouteSet
      class NamedRouteCollection
        def define_url_helper(mod, name, helper, url_strategy)
          mod.define_method(name) do |*args|
            last = args.last
            options = \
              case last
              when Hash
                args.pop
              when ActionController::Parameters
                args.pop.to_h
              end
            helper.call(self, name, args, options, url_strategy)
          end

          # because we heavily rely on the removed hash_for method in routes, we must add this monkey patch.
          mod.define_method("hash_for_#{name}") do |*args|
            inner_options = \
              case args.last
              when Hash
                args.pop
              when ActionController::Parameters
                args.pop.to_h
              end
            opts = helper.instance_variable_get(:@options)
            helper.send(:handle_positional_args,
              {},
              inner_options || {},
              args,
              opts.merge(:use_route => helper.route_name),
              helper.instance_variable_get(:@segment_keys))
          end
        end
      end
    end
  end
end
