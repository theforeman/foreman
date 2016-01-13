function filterCerts(state) {
  $('#certificates table').dataTable().fnFilter(state, 1, true);
}

function certTable() {
  activateDatatables();
  var filter = $('#puppetca-filter');
  filter.select2();
  filter.on('change', function() {filterCerts(filter.val())});
  filterCerts(__('valid')+'|'+__('pending'));
}
