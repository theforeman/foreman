providerSpecificNICInfo = function(form) {
  return form.find('select.ovirt_name').val() + ' @ ' + form.find('select.ovirt_network :selected').text();
}
