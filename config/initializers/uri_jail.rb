class URI::Generic::Jail < Safemode::Jail
  allow :host, :path, :port, :query, :scheme
end
