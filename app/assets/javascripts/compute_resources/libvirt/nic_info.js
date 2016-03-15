providerSpecificNICInfo = function(form) {
  if (form.find('select.libvirt_network').val() == 'network') {
    return Jed.sprintf(__('physical @ NAT %s'), form.find('select.libvirt_nat').val());
  } else {
    return Jed.sprintf(__('physical @ bridge %s'), form.find('select.libvirt_bridge').val());
  }
}
