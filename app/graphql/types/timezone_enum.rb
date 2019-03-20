module Types
  class TimezoneEnum < Types::BaseEnum
    ActiveSupport::TimeZone.all.each do |timezone|
      value timezone.name.gsub(/[^_a-zA-Z0-9]/, '_'), description: timezone.to_s, value: timezone.name
    end
  end
end
