module UnattendedHelper
  include Foreman::Renderer

  def ks_console
    (@port and @baud) ? "console=ttyS#{@port},#{@baud}": ""
  end

  def grub_pass
    @grub ? "--md5pass=#{@system.root_pass}": ""
  end

  def root_pass
    @system.root_pass
  end

end
