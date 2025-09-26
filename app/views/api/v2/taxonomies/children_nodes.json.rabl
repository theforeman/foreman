child @object.locations.merge(Location.my_locations).authorized_as(User.current, :view_locations, Location) => :locations do
  extends "api/v2/taxonomies/base"
end

child @object.organizations.merge(Organization.my_organizations).authorized_as(User.current, :view_organizations, Organization) => :organizations do
  extends "api/v2/taxonomies/base"
end
