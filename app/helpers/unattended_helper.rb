module UnattendedHelper
  def ks_console
    (@port && @baud) ? "console=ttyS#{@port},#{@baud}" : ""
  end

  def grub_pass
    if @grub
      @host.grub_pass.start_with?('$1$') ? "--md5pass=#{@host.grub_pass}" : "--iscrypted --password=#{@host.grub_pass}"
    else
      ""
    end
  end

  def root_pass
    @host.root_pass
  end
end
