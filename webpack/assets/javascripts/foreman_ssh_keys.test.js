jest.unmock('./foreman_ssh_keys');
const $ = require('jquery');
const sshKeys = require('./foreman_ssh_keys');

describe('autofillSshKeyName', () => {
  it('updates name field with ssh key comment', () => {
    document.body.innerHTML = `<textarea id="ssh_key_key">ssh-rsa 12345 mycomment</textarea>
      <input type="test" id="ssh_key_name">`;

    sshKeys.autofillSshKeyName();
    expect($('#ssh_key_name').val()).toEqual('mycomment');
  });
});
