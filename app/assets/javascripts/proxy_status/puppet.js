function filterCerts(state) {
  $('#certificates table').dataTable().fnFilter(state, 1, true);
}

function certTable() {
  tfm.tools.activateDatatables();
  var filter = $('#puppetca-filter');
  tfm.tools.activateSelect2(filter);
  filter.on('change', function() {filterCerts(filter.val())});
  filterCerts(__('valid')+'|'+__('pending'));
}
