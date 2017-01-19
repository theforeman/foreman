jest.unmock('./NotificationDrawerTitle');

import React from 'react';
import { shallow } from 'enzyme';
import NotificationDrawerTitle from './NotificationDrawerTitle';

function setup(title) {
  return shallow(<NotificationDrawerTitle text={title} />);
}

describe('NotificationDrawerTitle', () => {
  it('displays title', () => {
    const wrapper = setup('Drawer Title');
    const title = wrapper.find('h3');

    expect(title.text()).toBe('Drawer Title');
  });
});
