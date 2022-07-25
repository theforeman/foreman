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

  def describe_hostgroup(&block)
    description = HostgroupDescription.new
    description.instance_eval(&block)
    description
  end

  def register_hostgroup_description(&block)
    @local_hostgroup_descriptions ||= []
    @local_hostgroup_descriptions << describe_hostgroup(&block)
  end

  def hostgroup_descriptions
    hostgroup_descriptions_from_plugins + (@local_hostgroup_descriptions || [])
  end

  class << self
    private

    def host_descriptions_from_plugins
      Foreman::Plugin.all.map { |plugin| plugin.host_ui_description }.compact
    end

    def hostgroup_descriptions_from_plugins
      Foreman::Plugin.all.map { |plugin| plugin.hostgroup_ui_description }.compact
    end
  end
end
