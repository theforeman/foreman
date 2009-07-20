module Components
  def self.included(base) #:nodoc:
    base.class_eval do
      include InstanceMethods
      extend ClassMethods
      helper HelperMethods

      # If this controller was instantiated to process a component request,
      # +parent_controller+ points to the instantiator of this controller.
      attr_accessor :parent_controller

      alias_method_chain :process_cleanup, :render_component
      alias_method_chain :session=, :render_component
      alias_method_chain :flash, :render_component
      alias_method_chain :assign_shortcuts, :render_component
      alias_method_chain :send_response, :render_component

      alias_method :component_request?, :parent_controller
    end
  end

  module ClassMethods
    # Track parent controller to identify component requests
    def process_with_components(request, response, parent_controller = nil) #:nodoc:
      controller = new
      controller.parent_controller = parent_controller
      controller.process(request, response)
    end
  end

  module HelperMethods
    def render_component(options)
      @controller.__send__(:render_component_as_string, options)
    end
  end

  module InstanceMethods
    # Extracts the action_name from the request parameters and performs that action.
    def process_with_components(request, response, method = :perform_action, *arguments) #:nodoc:
      flash.discard if component_request?
      process_without_components(request, response, method, *arguments)
    end
    
    def send_response_with_render_component
      response.prepare! unless component_request?
      response
    end

    protected
      # Renders the component specified as the response for the current method
      def render_component(options) #:doc:
        component_logging(options) do
          render_for_text(component_response(options, true).body, response.headers["Status"])
        end
      end

      # Returns the component response as a string
      def render_component_as_string(options) #:doc:
        component_logging(options) do
          response = component_response(options, false)

          if redirected = response.redirected_to
            render_component_as_string(redirected)
          else
            response.body
          end
        end
      end

      def flash_with_render_component(refresh = false) #:nodoc:
        if !defined?(@_flash) || refresh
          @_flash =
            if defined?(@parent_controller)
              @parent_controller.flash
            else
              flash_without_render_component
            end
        end
        @_flash
      end

    private
      def component_response(options, reuse_response)
        klass    = component_class(options)
        request  = request_for_component(klass.controller_path, options)
        new_response = reuse_response ? response : response.dup

        klass.process_with_components(request, new_response, self)
      end

      # determine the controller class for the component request
      def component_class(options)
        if controller = options[:controller]
          controller.is_a?(Class) ? controller : "#{controller.camelize}Controller".constantize
        else
          self.class
        end
      end

      # Create a new request object based on the current request.
      # The new request inherits the session from the current request,
      # bypassing any session options set for the component controller's class
      def request_for_component(controller_path, options)
        new_request         = request.dup
        new_request.session = request.session

        new_request.instance_variable_set(
          :@parameters,
          (options[:params] || {}).with_indifferent_access.update(
            "controller" => controller_path, "action" => options[:action], "id" => options[:id]
          )
        )

        new_request
      end

      def component_logging(options)
        if logger
          logger.info "Start rendering component (#{options.inspect}): "
          result = yield
          logger.info "\n\nEnd of component rendering"
          result
        else
          yield
        end
      end

      def session_with_render_component=(options = {})
        session_without_render_component=(options) unless component_request?
      end

      def process_cleanup_with_render_component
        process_cleanup_without_render_component unless component_request?
      end
      
      def assign_shortcuts_with_render_component(request, response)
        assign_shortcuts_without_render_component(request, response)
        flash(:refresh)
        flash.sweep if @_session && !component_request?
      end
  end
end