/* eslint-disable jquery/no-val */

import fs from 'fs';
import path from 'path';
import $ from 'jquery';
import { changeLdapPort } from './foreman_auth_source';

jest.unmock('jquery');
jest.unmock('./foreman_auth_source');

const SAMPLE_CACERT = fs.readFileSync(
  path.join(
    __dirname,
    '../../../test/static_fixtures/certificates/example.com.crt'
  ),
  'utf8'
);

describe('AuthSourceLDAP tests', () => {
  let tlsCheckbox;

  beforeEach(() => {
    document.body.innerHTML = `
    <input type="checkbox" name="auth_source_ldap[tls]" id="auth_source_ldap_tls">
    <input min="1" max="65535" data-default-ports="{&quot;ldap&quot;:389,&quot;ldaps&quot;:636}" class="form-control " type="number" value="389" name="auth_source_ldap[port]" id="auth_source_ldap_port">
    <div id="auth_source_ldap_cacert_group" class="form-group hide" style="display: none;">
      <textarea name="auth_source_ldap[cacert]" id="auth_source_ldap_cacert"></textarea>
    </div>
    `;
    tlsCheckbox = document.getElementById('auth_source_ldap_tls');
  });

  it('change LDAP port', () => {
    tlsCheckbox.checked = true;
    changeLdapPort(tlsCheckbox);
    expect($('#auth_source_ldap_port').val()).toEqual('636');

    tlsCheckbox.checked = false;
    changeLdapPort(tlsCheckbox);
    expect($('#auth_source_ldap_port').val()).toEqual('389');
  });

  it('toggles CA certificate field with LDAPS', () => {
    const cacertGroup = document.getElementById(
      'auth_source_ldap_cacert_group'
    );

    tlsCheckbox.checked = true;
    changeLdapPort(tlsCheckbox);
    expect(cacertGroup.style.display).not.toBe('none');

    tlsCheckbox.checked = false;
    changeLdapPort(tlsCheckbox);
    expect(cacertGroup.style.display).toBe('none');
  });

  it('clears the CA certificate when LDAPS is disabled', () => {
    $('#auth_source_ldap_cacert').val(SAMPLE_CACERT);

    tlsCheckbox.checked = false;
    changeLdapPort(tlsCheckbox);
    expect($('#auth_source_ldap_cacert').val()).toEqual('');
  });

  it('keeps the CA certificate when LDAPS stays enabled', () => {
    $('#auth_source_ldap_cacert').val(SAMPLE_CACERT);

    tlsCheckbox.checked = true;
    changeLdapPort(tlsCheckbox);
    expect($('#auth_source_ldap_cacert').val()).toEqual(SAMPLE_CACERT);
  });
});
