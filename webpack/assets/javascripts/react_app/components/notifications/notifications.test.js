import React from 'react';
import {shallow, mount} from 'enzyme';
import Notifications from './';
import thunk from 'redux-thunk';
import configureMockStore from 'redux-mock-store';
import {getStore} from '../../redux';
import {
  emptyState,
  emptyHtml,
  stateWithoutNotifications,
  stateWithNotifications,
  stateWithUnreadNotifications,
  serverResponse
} from './notifications.fixtures';
jest.unmock('jquery');
const mockStore = configureMockStore([thunk]);

describe('notifications', () => {
  const $ = require('jquery');

  beforeEach(() => {
    global.__ = str => str;
    global.tfm = {
      tools: {
        activateTooltips: () => {}
      }
    };

    $.getJSON = jest.genMockFunction().mockImplementation(url => {
      return {
        then: function (callback) {
          callback(JSON.parse(serverResponse));
        }
      };
    });
  });

  it('empty state', () => {
    const store = mockStore(emptyState);

    const box = shallow(<Notifications store={store} />);

    expect(box.render().html()).toEqual(emptyHtml);
  });

  it('should render empty html for state before notifications', () => {
    const store = mockStore(stateWithoutNotifications);

    const box = shallow(<Notifications store={store} />);

    expect(box.render().find('.drawer-pf').length).toEqual(0);
  });

  it('should render full html on a state with notifications', () => {
    const store = mockStore(stateWithNotifications);
    const box = shallow(<Notifications store={store} />);

    expect(box.render().find('.drawer-pf-notification').length).toEqual(1);
  });

  it('should display full bell on a state with unread notifications', () => {
    const store = mockStore(stateWithUnreadNotifications);
    const box = shallow(<Notifications store={store} />);

    expect(box.render().find('.fa-bell').length).toBe(1);
  });

  it('full flow', () => {
    const data = {url: '/notification_recipients'};
    const wrapper = mount(<Notifications data={data} store={getStore()} />);

    wrapper.find('.fa-bell').simulate('click');
    expect(wrapper.find('.panel-group').length).toEqual(1);
    wrapper.find('.panel-group .panel-heading').simulate('click');
    expect(wrapper.find('.not-seen').length).toEqual(1);
    wrapper.find('.not-seen').simulate('click');
    expect(wrapper.find('.not-seen').length).toEqual(0);
  });

  it('mark group as read flow', () => {
    const data = {url: '/notification_recipients'};
    const wrapper = mount(<Notifications data={data} store={getStore()} />);
    const matcher = '.drawer-pf-action a.btn-link';

    wrapper.find('.fa-bell').simulate('click');
    wrapper.find('.panel-group .panel-heading').simulate('click');
    expect(wrapper.find(matcher).length).toBe(1);
    expect(wrapper.find(`${matcher}[disabled=true]`).length).toBe(0);
    wrapper.find(matcher).simulate('click');
    expect(wrapper.find(`${matcher}[disabled=true]`).length).toBe(1);
  });

  it('should redirect to login when 401', () => {
    window.location.replace = jest.fn();
    $.getJSON = jest.genMockFunction().mockImplementation(url => {
      return {
        then: function (callback, failCallback) {
          failCallback({status: 401});
        }
      };
    });
    const data = {url: '/notification_recipients'};

    mount(<Notifications data={data} store={getStore()} />);
    expect(global.location.replace).toBeCalled();
  });
});
