module UnattendedHelper
  def self.included(base)
    base.send :include, DefaultSafeRender
    base.class_eval { protected :default_safe_render }
  end

  def ks_console
    (@port and @baud) ? "console=ttyS#{@port},#{@baud}": ""
  end

  def grub_pass
    @grub ? "--md5pass=#{@host.root_pass}": ""
  end

  def root_pass
    @host.root_pass
  end

  def foreman_url(action = "built")
    url_for :only_path => false, :controller => "/unattended", :action => action,
      :host      => (Setting[:foreman_url] unless Setting[:foreman_url].blank?),
      :protocol  => 'http',
      :token     => (@host.token.value unless @host.token.nil?)
  end
  attr_writer(:url_options)

  # provide embedded snippets support as simple erb templates
  def snippets(file)
    if ConfigTemplate.where(:name => file, :snippet => true).empty?
      render :partial => "unattended/snippets/#{file}"
    else
      return snippet(file.gsub(/^_/, ""))
    end
  end

  def snippet name
    if (template = ConfigTemplate.where(:name => name, :snippet => true).first)
      Rails.logger.debug "rendering snippet #{template.name}"
      begin
        return default_safe_render(template.template)
      rescue Exception => exc
        raise Foreman::Exception.new("The snippet '%{name}' threw an error: %{e}", { :name => name, :e => exc })
      end
    else
      raise Foreman::Exception.new("The specified snippet '%{name}' does not exist, or is not a snippet.", {:name => name})
    end
  end

end
