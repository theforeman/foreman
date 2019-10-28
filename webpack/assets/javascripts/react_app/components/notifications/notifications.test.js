/* eslint-disable no-console */
import React from 'react';
import IntegrationTestHelper from '../../common/IntegrationTestHelper';
import notificationReducer from '../../redux/reducers/notifications';
import { reducers as APIReducers } from '../../redux/API/APIReducer';
import { get } from '../../redux/API/APIRequest';
import { componentMountData } from './notifications.fixtures';
import Notifications from './';
import { APIMiddleware } from '../../redux/API';
import { registeredPollingException } from '../../redux/API/APIHelpers';
import { NOTIFICATIONS } from '../../redux/consts';

jest.mock('../../redux/API/APIRequest');

const notificationProps = {
  data: componentMountData,
};

const configureIntegrationHelper = () => {
  const reducers = { notifications: notificationReducer, ...APIReducers };
  const middlewares = [APIMiddleware];
  return new IntegrationTestHelper(reducers, middlewares);
};

describe('notifications', () => {
  beforeEach(() => {
    global.tfm = {
      tools: {
        activateTooltips: () => {},
      },
    };
    jest.spyOn(console, 'error');
    console.error.mockImplementation(() => {});
  });

  afterEach(() => {
    console.error.mockRestore();
    get.mockRestore();
  });

  it('should avoid multiple polling on re-mount', () => {
    get.mockImplementation(jest.fn());
    const integrationTestHelper = configureIntegrationHelper();
    integrationTestHelper.mount(<Notifications {...notificationProps} />);
    try {
      integrationTestHelper.mount(<Notifications {...notificationProps} />);
    } catch (error) {
      expect(error.message).toBe(
        registeredPollingException(NOTIFICATIONS).message
      );
    }
    expect(get).toHaveBeenCalledTimes(1);
  });
});
