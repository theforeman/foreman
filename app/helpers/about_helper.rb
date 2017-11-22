module AboutHelper
  def plugins
    @plugins.map do |plugin|
      {:name => {name: plugin.name, url: plugin.url}, :description => plugin.description,
       :author => plugin.author, :version => plugin.version }
    end
  end

  def proxies
    @smart_proxies.map  do |proxy|
      {:id => {:name => proxy.name, :id => proxy.id},
       :features => proxy.features.map(&:name).to_sentence}
    end
  end

  def providers
    nil unless SETTINGS[:unattended]
    @providers.map do |provider|
      {:provider => provider[:friendly_name],
       :status => provider[:status] == :installed}
    end
  end

  def compute_resources
    nil unless SETTINGS[:unattended]
    @compute_resources.map do |compute|
      {:id => {:name => compute.name, :id => compute.id},
       :type => compute.provider_friendly_name}
    end
  end

  def about_data
    {:compute => compute_resources, :proxy => proxies, :plugin => plugins, :provider => providers }
  end
end
