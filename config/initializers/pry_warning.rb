if ENV['PRY_WARNING'] && defined? pry
  Rails.logger.warn "WARNING: Pry will not work with foreman gem, use script/foreman-start-dev"
end
