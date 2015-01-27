//= require spice-html5

var sc = null;
$(function () {
  var scheme = "ws://", uri;

  var host = window.location.hostname;
  var port = $('#spice-area').data('port');
  var password = $('#spice-area').data('password');

  if ((!host) || (!port)) {
    console.log(__("must set host and port"));
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
  $('#spice-status').removeClass('label-success').addClass('label-danger');
  disconnect();
}

function spice_success(m) {
  $('#spice-status').text(Jed.sprintf(__('Connected (unencrypted) to: %s'), $('#spice-status').attr('data-host')))
  $('#spice-status').addClass('label-success');
}

function connectXPI() {
  if ($('#spice-xpi').length == 0) {
    $('#spice-area').append('<embed type="application/x-spice" height=0 width=0 id="spice-xpi">');
  }
  var attrs = $('#spice-area');
  // we close down the other WebSocket connection when opening the XPI
  disconnect();
  var pluginobj = document.embeds[0];
  pluginobj.hostIP = attrs.data('address');
  pluginobj.SecurePort = attrs.data('secure-port');
  pluginobj.Password = attrs.data('password');
  pluginobj.TrustStore = decodeURIComponent(attrs.data('ca-cert'));
  pluginobj.SSLChannels = String("all");
  pluginobj.fullScreen = false;
  pluginobj.Title = attrs.data('title');
  pluginobj.HostSubject = attrs.data('subject');
  pluginobj.connect();
}
