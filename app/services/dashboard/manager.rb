module Dashboard
  module Manager
    @default_widgets = []
    @allowed_templates = Set.new()

    def self.default_widgets
      @default_widgets
    end

    def self.register_default_widget(widget)
      @default_widgets << widget
      @allowed_templates << widget[:template]
    end

    def self.register_allowed_templates(templates)
      @allowed_templates.merge(templates)
    end

    def self.add_widget_to_user(user, widget)
      raise ::Foreman::Exception.new(N_("Unallowed template for dashboard widget: %s"), widget[:template]) unless @allowed_templates.include?(widget[:template])
      user.widgets.create!(widget)
    end

    def self.reset_user_to_default(user)
      user.widgets.clear
      @default_widgets.each {|widget|
        add_widget_to_user(user, widget)
      }
    end
  end
end
