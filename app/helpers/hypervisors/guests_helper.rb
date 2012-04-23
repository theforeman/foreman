module Hypervisors::GuestsHelper

  def state s
    s ? " Off" : " On"
  end

  def power_class s
    "class='label #{s ? "label-success" : ""}'"
  end

  def power_action guest
    opts = hash_for_power_hypervisor_guest_path(:hypervisor_id => @hypervisor, :id => guest)
    html =  guest.running? ?  { :confirm => 'Are you sure?', :class => "btn btn-small btn-danger" } : { :class => "btn btn-small btn-info" }

    display_link_if_authorized "Power#{state(guest.running?)}" , opts, html.merge(:method => :put)
  end
end
