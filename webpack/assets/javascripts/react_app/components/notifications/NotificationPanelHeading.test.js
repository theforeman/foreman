jest.unmock('./NotificationPanelHeading');

import React from 'react';
import { mount } from 'enzyme';
import NotificationPanelHeading from './NotificationPanelHeading';

function setup() {
  return mount(<NotificationPanelHeading title="Panel Heading" unread="12" />);
}

describe('NotificationPanelHeading', () => {
  it('shows title', () => {
    const wrapper = setup();

    expect(wrapper.find('.panel-title a').text()).toBe('Panel Heading');
  });
  it('shows number of unread', () => {
    const wrapper = setup();
    const counterText = wrapper.find('.panel-counter').text();

    expect(counterText.substring(0, 2)).toBe('12');
  });
});
