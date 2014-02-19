object @architecture

extends "api/v2/architectures/main"

child :operatingsystems do
  extends "api/v2/operatingsystems/base"
end

child :images do
  extends "api/v2/images/base"
end
