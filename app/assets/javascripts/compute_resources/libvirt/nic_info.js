providerSpecificNICInfo = function(form) {
  if (form.find('select.libvirt_network').val() == 'network') {
    return tfm.i18n.sprintf(__('physical @ NAT %s'), form.find('select.libvirt_nat').val());
  } else {
    return tfm.i18n.sprintf(__('physical @ bridge %s'), form.find('select.libvirt_bridge').val());
  }
}
