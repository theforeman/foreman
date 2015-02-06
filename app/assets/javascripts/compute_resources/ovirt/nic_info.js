providerSpecificNICInfo = function(form) {
  return form.find('.ovirt_name').val() + ' @ ' + form.find('.ovirt_network').val();
}
