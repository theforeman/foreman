jest.unmock('./NotificationPanel');

import React from 'react';
import { shallow } from 'enzyme';
import NotificationPanel from './NotificationPanel';

function setup() {
  return shallow(<NotificationPanel />);
}

describe('NotificationPanel', () => {
  it('runs a test', () => {
    setup();
    expect('not implemented').toBeTruthy();
  });
});
