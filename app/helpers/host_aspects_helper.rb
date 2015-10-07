module HostAspectsHelper
  # override host's tabs to add all aspects as tabs
  def host_additional_tabs(host, host_form)
    base_tabs = super
    aspect_tabs = load_aspects(host, host_form)
    base_tabs.merge(aspect_tabs)
  end

  def load_aspects(host, host_form)
    host_aspects = {}

    host.host_aspects.each do |aspect|
      val = aspect.execution_model
      host_aspects[aspect.aspect_subject] = aspect_tab(aspect.aspect_subject, val, host_form) if val
    end
    host_aspects
  end

  def aspect_tab(subject, val, host_form)
    content_tag(:div, :id => subject, :class => "tab-pane") do
      render(val, :f => host_form)
    end
  end
end
