jest.unmock('./Notification');

import React from 'react';
import { mount } from 'enzyme';
import Notification from './Notification';

/* eslint-disable camelcase */
const notification = {
  id: 1,
  text: 'Job well done',
  level: 'success',
  created_at: '2016-12-13 16:52:47Z'
};
/* eslint-enable camelcase */

function setup(notification) {
  return mount(<Notification {...notification} />);
}

describe('Notification', () => {
  beforeEach(() => {
    global.__ = (text) => text;
    global.tfm = {
      tools: {
        activateTooltips: () => {}
      }
    };
  });

  it('displays text', () => {
    const wrapper = setup(notification);
    const messageElement = wrapper.find('.drawer-pf-notification-message');

    expect(messageElement.text()).toBe('Job well done');
  });
  it('displays icon', () => {
    const wrapper = setup(notification);
    const iconElement = wrapper.find('.pficon.pficon-ok.pull-left');

    expect(iconElement.length).toBe(1);

  });
  it('displays created date', () => {
    const wrapper = setup(notification);
    const dateElement = wrapper.find('.date');

    expect(dateElement.text()).toBe('12/13/16');
  });
  xit('displays created time', () => {
    const wrapper = setup(notification);
    const timeElement = wrapper.find('.time');

    expect(timeElement.text()).toBe('06:52:47 PM');
  });
});
