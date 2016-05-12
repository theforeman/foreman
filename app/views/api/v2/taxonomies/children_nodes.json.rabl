if SETTINGS[:locations_enabled]
  child :locations => :locations do
    extends "api/v2/taxonomies/base"
  end
end

if SETTINGS[:organizations_enabled]
  child :organizations => :organizations do
    extends "api/v2/taxonomies/base"
  end
end
