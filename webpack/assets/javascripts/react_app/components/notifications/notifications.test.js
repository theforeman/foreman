import { mount } from 'enzyme';
import React from 'react';
import { generateStore } from '../../redux';
import API from '../../redux/API/API';
import { doesDocumentHasFocus } from '../../common/document';
import IntegrationTestHelper from '../../common/IntegrationTestHelper';

import { componentMountData, serverResponse } from './notifications.fixtures';

import Notifications from './';

jest.mock('../../redux/API/API');
jest.mock('../../common/document');

describe('notifications', () => {
  doesDocumentHasFocus.mockImplementation(() => true);

  beforeEach(() => {
    global.tfm = {
      tools: {
        activateTooltips: () => {},
      },
    };
  });

  it('full flow', async () => {
    API.get = urlAPI =>
      new Promise((resolve, reject) => {
        resolve(JSON.parse(serverResponse));
      });
    const wrapper = mount(
      <Notifications data={componentMountData} store={generateStore()} />
    );
    await IntegrationTestHelper.flushAllPromises();
    wrapper.update();
    wrapper.find('.fa-bell').simulate('click');
    expect(wrapper.find('.panel-group')).toHaveLength(1);
    wrapper.find('.panel-group .panel-heading').simulate('click');
    expect(wrapper.find('.unread')).toHaveLength(1);
    wrapper.find('.unread').simulate('click');
    expect(wrapper.find('.unread')).toHaveLength(0);
  });

  it('should redirect to login when 401', async () => {
    window.location.replace = jest.fn();
    API.get = urlAPI =>
      new Promise((resolve, reject) => {
        // eslint-disable-next-line prefer-promise-reject-errors
        reject({ response: { status: 401 } });
      });
    mount(<Notifications data={componentMountData} store={generateStore()} />);
    await IntegrationTestHelper.flushAllPromises();
    expect(global.location.replace).toBeCalled();
  });

  it('should avoid multiple polling on re-mount', () => {
    const store = generateStore();
    API.get = urlAPI =>
      new Promise((resolve, reject) => {
        resolve(JSON.parse(serverResponse));
      });
    const spy = jest.spyOn(API, 'get');

    mount(<Notifications data={componentMountData} store={store} />);
    mount(<Notifications data={componentMountData} store={store} />);

    expect(spy).toHaveBeenCalledTimes(1);
  });
});
