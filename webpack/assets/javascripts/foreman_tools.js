export function showSpinner() {
  $('#turbolinks-progress').show();
}

export function hideSpinner() {
  $('#turbolinks-progress').hide();
}

export function iconText(name, innerText, iconClass) {
  let icon = '<span class="' + iconClass + ' ' + iconClass + '-' + name + '"/>';

  if (innerText !== '') {
    icon += '<strong>' + innerText + '</strong>';
  }
  return icon;
}
