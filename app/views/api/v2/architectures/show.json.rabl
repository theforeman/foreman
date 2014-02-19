object @architecture

extends "api/v2/architectures/main"

child :operatingsystems, :object_root => false do
  extends "api/v2/operatingsystems/base"
end

child :images, :object_root => false do
  extends "api/v2/images/base"
end
