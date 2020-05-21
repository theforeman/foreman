import React from 'react';
import { shallow } from '@theforeman/test';
import HostsCountCell from '../HostsCountCell';

describe('HostsCountCell', () => {
  it('should render link', () => {
    const text = 3;
    const view = shallow(
      <HostsCountCell name="model-x.1" controller="model">
        {text}
      </HostsCountCell>
    );
    expect(view.find('a').props().href).toBe(
      'hosts?search=model+%3D+"model-x.1"'
    );
    expect(view.find('a').text()).toBe(`${text}`);
  });
});
