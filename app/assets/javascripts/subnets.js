function showSubnetIPAM(element) {
  if (element.is(":checked"))
    $('#ipam_options').removeClass('hide');
  else
    $('#ipam_options').addClass('hide');
}

$(document).on('change', "#subnet_ipam", function () {
  showSubnetIPAM($(this));
});
