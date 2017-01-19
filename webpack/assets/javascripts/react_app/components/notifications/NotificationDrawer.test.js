jest.unmock('./NotificationDrawer');

import React from 'react';
import { shallow } from 'enzyme';
import NotificationDrawer from './NotificationDrawer';
import testHelpers from '../../common/testHelpers';

function setup() {
  return shallow(<NotificationDrawer />);
}

describe('NotificationDrawer', () => {
  beforeEach(() => {
    global.sessionStorage = testHelpers.mockStorage();
  });

  it('runs a test', () => {
    setup();
    expect('not implemented').toBeTruthy();
  });
});
