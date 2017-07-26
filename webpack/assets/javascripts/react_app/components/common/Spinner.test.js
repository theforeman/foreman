jest.unmock('./Spinner');

import React from 'react';
import { mount } from 'enzyme';
import Spinner from './Spinner';

const fixture = (
  <div>
  <Spinner />
  <Spinner size="lg" />
  <Spinner size="sm" />
  <Spinner size="xs" />
  <Spinner size="sm" inline={true}/>
  <div style={{backgroundColor: 'green'}}>
    <Spinner size="sm" inverse={true}/>
  </div>
</div>);

function setup() {
  return mount(fixture);
}
describe('Spinner', () => {
  let wrapper;

  beforeEach(function () { wrapper = setup(); });

  it('shows all spinners', () => {
    expect(wrapper.find('.spinner').length).toBe(6);
  });

  it('shows inline spinner', () => {
    expect(wrapper.find('.spinner-inline').length).toBe(1);
  });

  it('shows inverse spinner', () => {
    expect(wrapper.find('.spinner-inverse').length).toBe(1);
  });

  it('shows large spinner', () => {
    expect(wrapper.find('.spinner-lg').length).toBe(2);
  });

  it('shows small spinner', () => {
    expect(wrapper.find('.spinner-sm').length).toBe(3);
  });

  it('shows extra small spinner', () => {
    expect(wrapper.find('.spinner-xs').length).toBe(1);
  });
});
