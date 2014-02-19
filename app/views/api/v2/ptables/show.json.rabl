object @ptable

extends "api/v2/ptables/main"

attributes :layout

child :operatingsystems do
  extends "api/v2/operatingsystems/base"
end
