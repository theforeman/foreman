class Debian < Operatingsystem
  def preseed_server host
    media_uri(host).select(:host, :port).compact.join(':')
  end

  def preseed_path host
    media_uri(host).select(:path, :query).compact.join('?')
  end

  # Override the class representation, as this breaks many rails helpers
  def class
    Operatingsystem
  end

end
