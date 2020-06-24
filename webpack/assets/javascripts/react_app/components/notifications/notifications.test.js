import React from 'react';
import thunk from 'redux-thunk';
import IntegrationTestHelper from '../../common/IntegrationTestHelper';
import notificationReducer from '../../redux/reducers/notifications';
import { componentMountData, serverResponse } from './notifications.fixtures';
import Notifications from './';
import API from '../../redux/API/API';
import { NOTIFICATIONS } from '../../redux/consts';
import {
  IntervalMiddleware,
  reducers as intervalsReducer,
} from '../../redux/middlewares/IntervalMiddleware';
import { registeredIntervalException } from '../../redux/middlewares/IntervalMiddleware/IntervalHelpers';
import { DEFAULT_INTERVAL } from '../../redux/actions/notifications/constants';

jest.useFakeTimers();
jest.mock('../../redux/API/API');
jest.mock('../../redux/actions/notifications/constants', () => ({
  DEFAULT_INTERVAL: 5000,
}));

const notificationProps = {
  data: componentMountData,
};

const configureIntegrationHelper = () => {
  const reducers = {
    notifications: notificationReducer,
    intervals: intervalsReducer,
  };
  const middlewares = [thunk, IntervalMiddleware];
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
    API.get.mockImplementation(async () => serverResponse);

    const testHelper = configureIntegrationHelper();
    const wrapper = testHelper.mount(<Notifications {...notificationProps} />);
    expect(setInterval).toHaveBeenCalledTimes(1);
    expect(setInterval).toHaveBeenLastCalledWith(
      expect.any(Function),
      DEFAULT_INTERVAL
    );
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
    }, DEFAULT_INTERVAL);
  });

  it('should avoid multiple polling on re-mount', () => {
    const testHelper = configureIntegrationHelper();
    testHelper.mount(<Notifications {...notificationProps} />);
    try {
      testHelper.mount(<Notifications {...notificationProps} />);
    } catch (error) {
      expect(error.message).toBe(
        registeredIntervalException(NOTIFICATIONS).message
      );
    }
  });
});
