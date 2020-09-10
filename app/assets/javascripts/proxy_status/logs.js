function filterLogsReset() {
  var table = $('#table-proxy-status-logs').DataTable();
  table.search('').draw();
}

function filterLogsByLevel(filter) {
  filterLogsReset();
  var table = $('#table-proxy-status-logs').DataTable();
  table.column(1).search(filter, true, false).draw();
}

function filterLogsByMessage(expression) {
  filterLogsReset();
  changeFilterSelection(1);
  var table = $('#table-proxy-status-logs').DataTable();
  table.column(1).search('ERROR|FATAL', true, false).draw();
  table.column(2).search(expression, true, false).draw();
}

function changeFilterSelection(index) {
  var filter = $('#logs-filter');
  filter[0].options[index].selected = true
  filter.trigger('change');
  filterLogsByLevel(filter.val());
}

function activateLogsDataTable() {
  $('#table-proxy-status-logs').dataTable({
    dom: "<'row'<'col-md-6'f>r>t<'row'<'col-md-6'i><'col-md-6'p>>",
    autoWidth: false,
    columnDefs: [{
      width: "15%",
      targets: 0
    },{
      width: "10%",
      targets: 1
    }]});
  var filter = $('#logs-filter');
  activate_select2(filter);
  filter.on('change', function() { filterLogsByLevel(filter.val()) });

  $('#logEntryModal').on('show.bs.modal', function (event) {
    var link = $(event.relatedTarget);
    var modal = $(this);
    var datetime = link.data('time');
    var utc_datetime = link.data('utc-time');
    modal.find('#modal-bt-timegmt').text(utc_datetime);
    modal.find('#modal-bt-time').text(datetime);
    modal.find('#modal-bt-level').text(link.data('level'));
    if (link.data('message')) modal.find('#modal-bt-message').text(link.data('message'));
    if (link.data('backtrace')) modal.find('#modal-bt-backtrace').text(link.data('backtrace'));
  })
  // Activate tooltips for fields with ellipsis
  tfm.tools.activateTooltips('#table-proxy-status-logs');
}

function expireLogs(item, from) {
  table_url = item.getAttribute('data-url');
  errors_url = item.getAttribute('data-url-errors');
  modules_url = item.getAttribute('data-url-modules');
  if (table_url && errors_url && modules_url) {
    $.ajax({
      type: 'POST',
      url: table_url,
      data: 'from=' + from,
      success: function(result) {
        $("#logs").html(result);
        activateLogsDataTable();
      },
      complete: function(){
        reloadOnAjaxComplete(item);
      }
    })
    $.ajax({
      type: 'GET',
      url: errors_url,
      success: function(result) {
        $("#ajax-errors-card").html(result);
      },
      complete: function(){
        reloadOnAjaxComplete(item);
      }
    })
    $.ajax({
      type: 'GET',
      url: modules_url,
      success: function(result) {
        $("#ajax-modules-card").html(result);
      },
      complete: function(){
        reloadOnAjaxComplete(item);
      }
    })
  }
}
