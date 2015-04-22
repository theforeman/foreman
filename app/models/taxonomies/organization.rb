class Organization < Taxonomy
  include Foreman::ThreadSession::OrganizationModel
  include Foreman::Taxonomy::Shared
end
