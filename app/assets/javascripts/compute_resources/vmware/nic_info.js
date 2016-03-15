providerSpecificNICInfo = function(form) {
  return form.find('select.vmware_type').val() + ' @ ' + form.find('select.vmware_network').val();
}
