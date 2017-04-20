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

    def self.add_widget_to_user(user, widget_params)
      raise ::Foreman::Exception.new(N_("Unallowed template for dashboard widget: %s"), widget_params[:template]) unless @allowed_templates.include?(widget_params[:template])

      widget = user.widgets.build(widget_params.except(:name, :template))
      widget.name = widget_params[:name]
      widget.template = widget_params[:template]
      widget.save!
      widget
    end

    def self.reset_user_to_default(user)
      user.widgets.clear
      @default_widgets.each do |widget|
        add_widget_to_user(user, widget)
      end
    end

    def self.find_default_widget_by_name(name)
      @default_widgets.select { |widget| widget[:name] == name }
    end
  end
end
