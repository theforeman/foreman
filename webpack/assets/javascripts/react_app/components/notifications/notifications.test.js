import { mount } from 'enzyme';
import React from 'react';
import { generateStore } from '../../redux';
import API from '../../API';
import { doesDocumentHasFocus } from '../../common/document';

import { componentMountData, serverResponse } from './notifications.fixtures';

import Notifications from './';

jest.mock('../../API');
jest.mock('../../common/document');

let failResponse = { response: { status: 200 } };

function mockjqXHR() {
  return {
    then: callback => {
      callback(JSON.parse(serverResponse));
      return mockjqXHR();
    },
    catch: failCallback => {
      failCallback(failResponse);
      return mockjqXHR();
    },
  };
}

describe('notifications', () => {
  doesDocumentHasFocus.mockImplementation(() => true);

  beforeEach(() => {
    global.tfm = {
      tools: {
        activateTooltips: () => {},
      },
    };
    API.get = mockjqXHR;
  });

  it('full flow', () => {
    const wrapper = mount(
      <Notifications data={componentMountData} store={generateStore()} />
    );
    wrapper.find('.fa-bell').simulate('click');
    expect(wrapper.find('.panel-group')).toHaveLength(1);
    wrapper.find('.panel-group .panel-heading').simulate('click');
    expect(wrapper.find('.unread')).toHaveLength(1);
    wrapper.find('.unread').simulate('click');
    expect(wrapper.find('.unread')).toHaveLength(0);
  });

  it('should redirect to login when 401', () => {
    window.location.replace = jest.fn();
    failResponse = { response: { status: 401 } };

    mount(<Notifications data={componentMountData} store={generateStore()} />);
    expect(global.location.replace).toBeCalled();
  });

  it('should avoid multiple polling on re-mount', () => {
    const store = generateStore();
    const spy = jest.spyOn(API, 'get');

    mount(<Notifications data={componentMountData} store={store} />);
    mount(<Notifications data={componentMountData} store={store} />);

    expect(spy).toHaveBeenCalledTimes(1);
  });
});
