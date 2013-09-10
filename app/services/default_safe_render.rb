module DefaultSafeRender
  ALLOWED_METHODS = [ :foreman_url, :grub_pass, :snippet, :snippets,
          :ks_console, :root_pass, :multiboot, :jumpstart_path, :install_path,
          :miniroot, :media_path ]
  ALLOWED_VARS = Proc.new() do
    { :arch => @arch, :host => @host, :osver => @osver,
      :mediapath => @mediapath, :static => @static, :yumrepo => @yumrepo,
      :dynamic => @dynamic, :epel => @epel, :kernel => @kernel, :initrd => @initrd,
      :preseed_server => @preseed_server, :preseed_path => @preseed_path }
  end

  def default_safe_render(to_parse)
    SafeRender.new(:methods => DefaultSafeRender::ALLOWED_METHODS,
                   :variables => (instance_eval &DefaultSafeRender::ALLOWED_VARS)).parse to_parse
  end
end
