object @subnet

extends "api/v2/subnets/main"

child :domains do
  extends "api/v2/domains/base"
end
