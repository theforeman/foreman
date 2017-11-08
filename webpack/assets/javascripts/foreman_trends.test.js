import $ from 'jquery';

jest.unmock('./foreman_trends');
window.trends = require('./foreman_trends');

describe('selecting trend type', () => {
  it('should disable fields on non-fact trend', () => {
    document.body.innerHTML =
    `<select id="trendable_type" onchange="trends.trendTypeSelected(this)">
      <option value="FactName">Facts</option>
      <option value="Hostgroup">Host group</option>
    </select>
    <select id="trend_trendable_id">
      <option value=""></option>
      <option value="27">architecture</option>
    </select>
    <input id="trend_name">`;
    $('#trendable_type').val('Hostgroup').change();
    expect($('#trend_trendable_id').is(':disabled')).toBeTruthy();
    expect($('#trend_name').is(':disabled')).toBeTruthy();
  });

  it('should enable fields on non-fact trend', () => {
    document.body.innerHTML =
    `<select id="trendable_type" onchange="trends.trendTypeSelected(this)">
      <option value="Evironment">Environment</option>
      <option value="FactName">Facts</option>
    </select>
    <select id="trend_trendable_id" disabled>
      <option value=""></option>
      <option value="27">architecture</option>
    </select>
    <input id="trend_name" disabled>`;
    $('#trendable_type').val('FactName').change();
    expect($('#trend_trendable_id').is(':disabled')).toBeFalsy();
    expect($('#trend_name').is(':disabled')).toBeFalsy();
  });
});
