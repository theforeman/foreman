module Hypervisors::GuestsHelper

  def state s
    s ? "Off" : "On"
  end
end
