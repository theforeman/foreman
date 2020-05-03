import React from 'react';
import thunk from 'redux-thunk';
import IntegrationTestHelper from '../../common/IntegrationTestHelper';
import notificationReducer from '../../redux/reducers/notifications';
import { componentMountData, serverResponse } from './notifications.fixtures';
import Notifications from './';
import API from '../../redux/API/API';
import { APIMiddleware, reducers as apiReducer } from '../../redux/API';

jest.mock('../../redux/API/API');

const notificationProps = {
  data: componentMountData,
};

const configureIntegrationHelper = () => {
  const reducers = { notifications: notificationReducer, ...apiReducer };
  const middlewares = [thunk, APIMiddleware];
  return new IntegrationTestHelper(reducers, middlewares);
};

describe('notifications', () => {
  beforeEach(() => {
    global.tfm = {
      tools: {
        activateTooltips: () => {},
      },
    };
  });

  it('full flow', () => {
    API.get.mockImplementation(() => serverResponse);

    const testHelper = configureIntegrationHelper();
    const wrapper = testHelper.mount(<Notifications {...notificationProps} />);

    /** this is a workaround to wait for the component
     * to get updated with the notification data.
     * I tried to use all of jest`s timer-mocking-functions with no success,
     * found no regression in test time duration */
    setTimeout(() => {
      wrapper.find('.fa-bell').simulate('click');
      expect(wrapper.find('.panel-group')).toHaveLength(1);
      wrapper.find('.panel-group .panel-heading').simulate('click');
      expect(wrapper.find('.unread')).toHaveLength(1);
      wrapper.find('.unread').simulate('click');
      expect(wrapper.find('.unread')).toHaveLength(0);
    }, 1);
  });
});
