
sc = null;
$(function () {
  var scheme = "ws://", uri;

  var host = window.location.hostname;
  var port = $('#spice-area').data('port');
  var password = $('#spice-area').data('password');

  if ((!host) || (!port)) {
    console.log("must set host and port");
    return;
  }

  uri = scheme + host + ":" + port;

  sc = new SpiceMainConn({uri: uri, screen_id: "spice-screen", password: password,
                          onerror: spice_error, onsuccess: spice_success});
});

function disconnect() {
  if (sc) { sc.stop(); }
}

function spice_error(e) {
  $('#spice-status').text(e);
  $('#spice-status').removeClass('label-success').addClass('label-important');
  disconnect();
}

function spice_success(m) {
  $('#spice-status').text($('#spice-status').text().replace('Connecting','Connected'));
  $('#spice-status').addClass('label-success');
}