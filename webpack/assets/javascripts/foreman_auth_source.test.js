/* eslint-disable jquery/no-val */

import $ from 'jquery';
import { changeLdapPort } from './foreman_auth_source';

jest.unmock('jquery');
jest.unmock('./foreman_auth_source');

describe('AuthSourceLDAP tests', () => {
  it('change LDAP port', () => {
    document.body.innerHTML = `
    <input min="1" max="65535" data-default-ports="{&quot;ldap&quot;:389,&quot;ldaps&quot;:636}" class="form-control " type="number" value="389" name="auth_source_ldap[port]" id="auth_source_ldap_port">
    `;
    const notChecked =
      '<input type="checkbox" name="auth_source_ldap[tls]" value="0""> ';
    const checked =
      '<input type="checkbox" name="auth_source_ldap[tls]" value="1" checked="checked"> ';
    changeLdapPort(checked);
    expect($('#auth_source_ldap_port').val()).toEqual('636');
    changeLdapPort(notChecked);
    expect($('#auth_source_ldap_port').val()).toEqual('389');
  });
});
