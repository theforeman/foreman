object @domain

extends "api/v2/domains/main"

child :subnets do
  extends "api/v2/subnets/base"
end

child :parameters => :parameters do
  extends "api/v2/parameters/base"
end
