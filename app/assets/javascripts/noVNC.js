"use strict";
var rfb;

function sendCtrlAltDel() {
  rfb.sendCtrlAltDel();
  return false;
}

function updateState(rfb, state, oldstate, msg) {
  var s, sb, cad, level;
  s = $D('noVNC_status');
  sb = $D('noVNC_status');
  cad = $D('sendCtrlAltDelButton');
  switch (state) {
    case 'failed':       level = "danger";  break;
    case 'fatal':        level = "danger";  break;
    case 'normal':       level = "success"; break;
    case 'disconnected': level = "default"; break;
    case 'loaded':       level = "success"; break;
    default:             level = "warning"; break;
  }

  cad.disabled = state !== "normal";

  if (typeof(msg) !== 'undefined') {
    sb.setAttribute("class", "col-md-7 label label-" + level);
    s.innerHTML = msg;
  }
}

$(function() {
  $D('sendCtrlAltDelButton').style.display = "inline";
  $D('sendCtrlAltDelButton').onclick = sendCtrlAltDel;

  var host = $('#vnc').data('host') ? $('#vnc').data('host') : window.location.hostname,
      port = $('#vnc').data('port'),
      password = $('#vnc').data('password'),
      token = $('#vnc').data('token'),
      path = '?token=' + token;
console.log(path);
  rfb = new RFB({'target': $D('noVNC_canvas'),
    'encrypt':      false,
    'true_color':   true,
    'local_cursor': true,
    'shared':      true,
    'view_only':   false,
    'updateState':  updateState});
  rfb.connect(host, port, password, path);
});
