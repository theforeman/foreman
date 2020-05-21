import React from 'react';
import { shallow } from '@theforeman/test';
import NameCell from '../NameCell';

describe('NameCell', () => {
  it('should render active link', () => {
    const text = 'KVM model';
    const view = shallow(
      <NameCell active id={1} name="KVM" controller="models">
        {text}
      </NameCell>
    );
    expect(view.find('a').props().href).toBe('/models/1-KVM/edit');
    expect(view.find('a').text()).toBe(text);
  });
  it('should render disabled link', () => {
    const text = 'HyperV model';
    const view = shallow(
      <NameCell id={2} name="HyperV" controller="models">
        {text}
      </NameCell>
    );
    expect(view.find('a').props().href).toBe('#');
    expect(view.find('a').props().disabled).toBe('disabled');
    expect(view.find('a').props().className).toBe('disabled');
    expect(view.find('a').text()).toBe(text);
  });
});
