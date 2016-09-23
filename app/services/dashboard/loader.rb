module Dashboard
  module Loader
    # Default widgets that are displayed on the dashboard
    DEFAULT_WIDGETS = [ {:template=>'status_widget',       :sizex=>8,:sizey=>1,:name=> N_('Host Configuration Status')},
                        {:template=>'status_chart_widget', :sizex=>4,:sizey=>1,:name=> N_('Host Configuration Chart')},
                        {:template=>'reports_widget',      :sizex=>6,:sizey=>1,:name=> N_('Latest Events')},
                        {:template=>'distribution_widget', :sizex=>6,:sizey=>1,:name=> N_('Run Distribution Chart')}]
    # Widget templates that are allowed on dashboard. Default widgets automatically allow their templates.
    ALLOWED_TEMPLATES = []

    def self.load
      DEFAULT_WIDGETS.each{ |widget| Dashboard::Manager.register_default_widget(widget) }
      Dashboard::Manager.register_allowed_templates(ALLOWED_TEMPLATES)
    end
  end
end
