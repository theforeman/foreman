/* eslint-disable jquery/no-is */
/* eslint-disable jquery/no-sizzle */
/* eslint-disable jquery/no-val */

import $ from 'jquery';
import { nfsVisibility } from './foreman_medium';

jest.unmock('jquery');
jest.unmock('./foreman_medium');
const nfsRequired = ['Solaris'];

document.body.innerHTML = `<span id="nfs-section" style=display:none;>
  <span class="help-block help-inline">The NFS path to the media.</span>
  <span class="help-block help-inline">The NFS path to the jumpstart control files.</span>
  <span class="help-block help-inline">The NFS path to the image directory.</span>
</span>
<select id='os_family' id="medium_os_family">
  <option value="">Choose a family</option>
  <option value="Redhat">Red Hat</option>
  <option value="Solaris">Solaris</option>
</select>`;

it('When an os family with required nfs is chosen, nfs section should be visable', () => {
  $.fn.show = jest.fn();
  expect($('#os_family').is(':visible')).toBe(false);
  $('#os_family').val('Solaris');
  nfsVisibility($('#os_family')[0], nfsRequired);
  expect($.fn.show).toBeCalled();
});

it('When an os family without required nfs is chosen, nfs section should be hidden', () => {
  $.fn.hide = jest.fn();
  $('#os_family').val('Redhat');
  nfsVisibility($('#os_family')[0], nfsRequired);
  expect($.fn.hide).toBeCalled();
});
