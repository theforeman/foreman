# Compute Profiles - only create if there are not any
if ComputeProfile.unconfigured?
  ComputeProfile.without_auditing do
    [
      { :name => '1-Small' },
      { :name => '2-Medium' },
      { :name => '3-Large' },
    ].each do |input|
      cp = ComputeProfile.create input
      raise "Unable to create hardware profile: #{SeedHelper.format_errors m}" if cp.nil? || cp.errors.any?
    end
  end
end
