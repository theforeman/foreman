export function showSpinner() {
  $('#turbolinks-progress').show();
}

export function hideSpinner() {
  $('#turbolinks-progress').hide();
}

export function iconText(name, inner_text, icon_class) {
  let icon = '<span class="' + icon_class + ' ' + icon_class + '-' + name + '"/>';
  if (inner_text !== '') {
    icon += '<strong>' + inner_text + '</strong>';
  }
  return icon;
}
