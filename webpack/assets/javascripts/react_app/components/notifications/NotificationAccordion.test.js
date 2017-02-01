jest.unmock('./NotificationAccordion');
jest.unmock('../../stores/NotificationsStore');

import React from 'react';
import { shallow } from 'enzyme';
import NotificationAccordion from './NotificationAccordion';
import testData from '../../stores/NotificationsTestData';
import NotificationsStore from '../../stores/NotificationsStore';
import testHelpers from '../../common/testHelpers';

function setup(data) {
  global.sessionStorage = testHelpers.mockStorage();
  return shallow(<NotificationAccordion notifications={data}/>);
}

describe('NotificationAccordion', () => {
  it('runs a test', () => {
    const data = NotificationsStore.prepareNotifications(testData);

    // eslint-disable-next-line no-unused-vars
    const wrapper = setup(data);

    expect('not implemented').toBeTruthy();
  });
});
