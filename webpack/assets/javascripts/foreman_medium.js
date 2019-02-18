import $ from '@theforeman/vendor/jquery';

export function nfsVisibility(osFamily, nfsRequired) {
  $('#nfs-section').toggle(nfsRequired.includes(osFamily.value));
}
