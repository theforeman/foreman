function showSubnetIPAM(element) {
  if (element.val() == element.data('disable-auto-suggest-on'))
    $('#ipam_options').addClass('hide');
  else
    $('#ipam_options').removeClass('hide');
}

$(document).on('change', "#subnet_ipam", function () {
  showSubnetIPAM($(this));
});
