$(document).on('ContentLoad', function() {
  $('a[data-toggle=\"tab\"]').on('shown.bs.tab', function (e) {
    $('a[rel="popover"]').popover("destroy");
  });
});
