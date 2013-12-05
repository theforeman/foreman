object @medium

extends "api/v2/media/main"

child :operatingsystems, :object_root => false do
  extends "api/v2/operatingsystems/base"
end