ActiveSupport::Notifications.subscribe("safemode_rendered.#{Foreman::Observable::DEFAULT_NAMESPACE}", ::Foreman::Rendering::SafemodeRenderedSubscriber)
ActiveSupport::Notifications.subscribe("safemode_rendering_error.#{Foreman::Observable::DEFAULT_NAMESPACE}", ::Foreman::Rendering::SafemodeErrorSubscriber)
ActiveSupport::Notifications.subscribe("unsafemode_rendered.#{Foreman::Observable::DEFAULT_NAMESPACE}", ::Foreman::Rendering::UnsafemodeRenderedSubscriber)
ActiveSupport::Notifications.subscribe("unsafemode_rendering_error.#{Foreman::Observable::DEFAULT_NAMESPACE}", ::Foreman::Rendering::UnsafemodeErrorSubscriber)
