import $ from 'jquery';

export function nfsVisibility(osFamily, nfsRequired) {
  $('#nfs-section').toggle(nfsRequired.includes(osFamily.value));
}
