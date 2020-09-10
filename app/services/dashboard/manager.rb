module Dashboard
  module Manager
    class << self
      def default_widgets
        Foreman::Plugin.all.inject(builtin_widgets) { |widgets, plugin| widgets + plugin.dashboard_widgets }
      end

      def add_widget_to_user(user, widget_params)
        raise ::Foreman::Exception.new(N_("Unallowed template for dashboard widget: %s"), widget_params[:template]) unless template_allowed?(widget_params[:template])

        widget = user.widgets.build(widget_params.except(:name, :template, :settings))
        widget.name = widget_params[:name]
        widget.template = widget_params[:template]
        widget.data = { :settings => widget_params[:settings] } if widget_params[:settings]
        widget.save!
        widget
      end

      def reset_user_to_default(user)
        user.widgets.clear
        default_widgets.each do |widget|
          add_widget_to_user(user, widget)
        end
      end

      def find_default_widget_by_name(name)
        default_widgets.select { |widget| widget[:name] == name }
      end

      private

      def builtin_widgets
        [
          (registered_report_orgins + ['All']).sort.flat_map do |origin|
            [
              {
                template: 'status_widget',
                sizex: 8,
                sizey: 1,
                name: N_('Host Configuration Status for %s') % origin,
                settings: {
                  origin: origin,
                  class_name: 'host-configuration-status',
                },
              },
              {
                template: 'status_chart_widget',
                sizex: 4,
                sizey: 1,
                name: N_('Host Configuration Chart for %s') % origin,
                settings: {
                  origin: origin,
                  class_name: 'host-configuration-chart-widget',
                },
              },
            ]
          end,
          registered_report_orgins.flat_map do |origin|
            {
              template: 'distribution_widget',
              sizex: 6,
              sizey: 1,
              name: N_('Run Distribution Chart for %s') % origin,
              settings: {
                origin: origin,
                class_name: 'run-distribution-chart',
              },
            }
          end,
          {template: 'reports_widget', sizex: 6, sizey: 1, name: N_('Latest Events')},
          {template: 'new_hosts_widget', sizex: 8, sizey: 1, name: N_('New Hosts')},
          {template: 'hosts_in_build_mode_widget', sizex: 8, sizey: 1, name: N_('Hosts in build mode')},
        ].flatten.sort_by { |widget| widget['name'] }
      end

      def registered_report_orgins
        Foreman::Plugin.report_origin_registry.origins_for('ConfigReport')
      end

      def template_allowed?(template)
        default_widgets.any? { |widget| widget[:template] == template }
      end
    end
  end
end
