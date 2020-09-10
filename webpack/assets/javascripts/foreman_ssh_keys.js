/* eslint-disable jquery/no-val */

import $ from 'jquery';

export function autofillSshKeyName() {
  const name = $('#ssh_key_name');
  const comment = $('#ssh_key_key')
    .val()
    .match(/^\S+ \S+ (.+)\n?$/);

  if (name.val() === '' && comment && comment.length >= 1) {
    return name.val(comment[1]).change();
  }

  return true;
}
