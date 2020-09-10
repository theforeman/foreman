providerSpecificNICInfo = function(form) {
  return form.find('.vmware_type').val() + ' @ ' + form.find('.vmware_network option:selected').text();
}
