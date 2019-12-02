/* eslint-disable jquery/no-val */

import $ from 'jquery';
import { autofillSshKeyName } from './foreman_ssh_keys';

jest.unmock('jquery');
jest.unmock('./foreman_ssh_keys');

describe('autofillSshKeyName', () => {
  it('updates name field with ssh key comment', () => {
    document.body.innerHTML = `<textarea id="ssh_key_key">ssh-rsa 12345 mycomment</textarea>
      <input type="test" id="ssh_key_name">`;

    autofillSshKeyName();
    expect($('#ssh_key_name').val()).toEqual('mycomment');
  });
});
