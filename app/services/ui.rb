module UI
  module_function

  def describe_host(&block)
    description = HostDescription.new
    description.instance_eval(&block)
    description
  end

  def register_host_description(&block)
    @local_host_descriptions ||= []
    @local_host_descriptions << describe_host(&block)
  end

  def host_descriptions
    host_descriptions_from_plugins + (@local_host_descriptions || [])
  end

  class << self
    private

    def host_descriptions_from_plugins
      Foreman::Plugin.all.map { |plugin| plugin.host_ui_description }.compact
    end
  end
end
