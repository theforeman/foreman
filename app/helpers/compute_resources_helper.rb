module ComputeResourcesHelper
  include LookupKeysHelper

  def vm_state s
    s ? "Off" : " On"
  end

  def vm_power_class s
    "class='label #{s ? "success" : ""}'"
  end

  def vm_power_action vm
    opts = hash_for_power_compute_resource_vm_path(:compute_resource_id => @compute_resource, :id => vm.identity)
    html = vm.ready? ? { :confirm => 'Are you sure?', :class => "label important" } : { :class => "label notice" }

    display_link_if_authorized "Power#{state(vm.ready?)}", opts, html.merge(:method => :put)
  end

  def memory_options max_memory
    gb = 1024*1024*1024
    opts = [0.25, 0.5, 0.75, 1, 2, 4, 8, 16]
    opts.map{|n| [number_to_human_size(n*gb), (n*gb).to_i] unless n > (max_memory / gb)}
  end
end
