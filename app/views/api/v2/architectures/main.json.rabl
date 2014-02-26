object @architecture

extends "api/v2/architectures/base"

child :operatingsystems do
  extends "api/v2/operatingsystems/base"
end

attributes :created_at, :updated_at
