module UnattendedHelper
  include Foreman::Renderer

  def ks_console
    (@port and @baud) ? "console=ttyS#{@port},#{@baud}": ""
  end

  def grub_pass
    @grub && PasswordCrypt.MD5?(@host.root_pass) ? "--md5pass=#{@host.root_pass}": ""
  end

  def root_pass
    @host.root_pass
  end

end
