function spice_error(e) {
  disconnect();
}

$(function () {
  var scheme = "ws://", uri;

  var host = window.location.hostname;
  var port = $('#spice-area').attr('data-port');
  var password = $('#spice-area').attr('data-password');

  if ((!host) || (!port)) {
    console.log("must set host and port");
    return;
  }

//  if (sc) {
//    sc.stop();
//  }

  uri = scheme + host + ":" + port;

  document.getElementById('disconnect').onclick = disconnect;

  try {
    sc = new SpiceMainConn({uri: uri, screen_id: "spice-screen", dump_id: "debug-div",
      message_id: "message-div", password: password, onerror: spice_error });
  }
  catch (e) {
    alert(e.toString());
    disconnect();
  }

});

function disconnect() {
  console.log(">> disconnect");
  if (sc) {
    sc.stop();
  }
  console.log("<< disconnect");
}
