(function () {
  "use strict";

  var extra = "", start, end;

  start = "<script src='/javascripts/spice/"
  end = "'><\/script>";

  var required = ["enums.js", "atKeynames.js", "utils.js", "png.js", "lz.js", "quic.js", "bitmap.js",
    "spicedataview.js", "spicetype.js", "spicemsg.js", "wire.js", "spiceconn.js", "display.js", "main.js",
    "inputs.js", "cursor.js", "thirdparty/jsbn.js", "thirdparty/rsa.js", "thirdparty/prng4.js",
    "thirdparty/rng.js", "thirdparty/sha1.js", "ticket.js"]

  required.forEach (function(script) {
    extra += start + script + end;
  });

  document.write(extra);
}());