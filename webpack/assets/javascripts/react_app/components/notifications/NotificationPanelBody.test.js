jest.unmock('./NotificationPanelBody');

import React from 'react';
import { shallow } from 'enzyme';
import NotificationPanelBody from './NotificationPanelBody';

function setup() {
  return shallow(<NotificationPanelBody />);
}

describe('NotificationPanelBody', () => {
  it('runs a test', () => {
    setup();
    expect('not implemented').toBeTruthy();
  });
});
