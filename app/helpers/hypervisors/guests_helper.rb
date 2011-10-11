module Hypervisors::GuestsHelper

  def state s
    s ? "Off" : " On"
  end

  def power_class s
    "class='label #{s ? "success" : ""}'"
  end

  def power_action guest
    opts = hash_for_power_hypervisor_guest_path(:hypervisor_id => @hypervisor, :id => guest)
    html =  guest.running? ?  { :confirm => 'Are you sure?', :class => "label important" } : { :class => "label notice" }

    display_link_if_authorized "Power#{state(guest.running?)}" , opts, html.merge(:method => :put)
  end
end
