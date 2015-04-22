class Location < Taxonomy
  include Foreman::ThreadSession::LocationModel
  include Foreman::Taxonomy::Shared
end
