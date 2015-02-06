providerSpecificNICInfo = function(form) {
  if (form.find('.libvirt_network').val() == 'network') {
    return Jed.sprintf(__('physical @ NAT %s'), form.find('.libvirt_nat').val());
  } else {
    return Jed.sprintf(__('physical @ bridge %s'), form.find('.libvirt_bridge').val());
  }
}
