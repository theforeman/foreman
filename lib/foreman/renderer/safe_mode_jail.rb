class URI::Generic::Jail < Safemode::Jail
  allow :host, :path, :port, :query, :scheme
end

class Hash::Jail < Safemode::Jail
  allow :to_json, :compact
end
