jest.unmock('./Notification');

import React from 'react';
import { mount } from 'enzyme';
import Notification from './Notification';

/* eslint-disable camelcase */
const notification = {
  id: 1,
  text: 'Job well done',
  level: 'success',
  created_at: '2016-12-13 16:52:47Z',
  actions: {
    'links': [
      {
        'href': 'https://theforeman.org',
        'title': 'Foreman blog'
      }
    ]
  }
};
/* eslint-enable camelcase */

function setup(notification) {
  return mount(<Notification {...notification} />);
}

describe('Notification', () => {
  let wrapper;

  beforeEach(() => {
    global.__ = (text) => text;
    global.tfm = {
      tools: {
        activateTooltips: () => {}
      }
    };
    wrapper = setup(notification);
  });

  it('displays text', () => {
    const messageElement = wrapper.find('.drawer-pf-notification-message');

    expect(messageElement.text()).toBe('Job well done');
  });
  it('displays icon', () => {
    const iconElement = wrapper.find('.pficon.pficon-ok.pull-left');

    expect(iconElement.length).toBe(1);

  });
  it('displays created date', () => {
    const dateElement = wrapper.find('.date');

    expect(dateElement.text()).toBe('12/13/16');
  });
  it('display actions dropdown if links are provided', () => {
    const dropdownMenu = wrapper.find('a');

    expect(dropdownMenu.props().href).toBe('https://theforeman.org');
    expect(dropdownMenu.text()).toBe('Foreman blog');
  });
  it('does not display actions dropdown if links are NOT provided', () => {
    let notificationWithoutAction = notification;

    delete notificationWithoutAction.actions.links;
    const dropdownMenu = setup(notificationWithoutAction).find('a');

    expect(dropdownMenu.node).not.toBeDefined();
  });
  xit('displays created time', () => {
    const timeElement = wrapper.find('.time');

    expect(timeElement.text()).toBe('06:52:47 PM');
  });
});
