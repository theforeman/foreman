// Configure Enzyme
import { configure } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
configure({ adapter: new Adapter() });

import React from 'react';
import { shallow, mount } from 'enzyme';
import toJson from 'enzyme-to-json';
import Notifications from './';
import thunk from 'redux-thunk';
import configureMockStore from 'redux-mock-store';
import { getStore } from '../../redux';
import {
  emptyState,
  componentMountData,
  stateWithoutNotifications,
  stateWithNotifications,
  stateWithUnreadNotifications,
  serverResponse,
} from './notifications.fixtures';
import API from '../../API';
jest.unmock('jquery');
const mockStore = configureMockStore([thunk]);

let failResponse = { status: 200 };

function mockjqXHR() {
  return {
    done: callback => {
      callback(JSON.parse(serverResponse));
      return mockjqXHR();
    },
    fail: failCallback => {
      failCallback(failResponse);
      return mockjqXHR();
    },
    always: () => {
      return mockjqXHR();
    },
  };
}

describe('notifications', () => {
  const $ = require('jquery');

  beforeEach(() => {
    global.__ = str => str;
    global.tfm = {
      tools: {
        activateTooltips: () => {},
      },
    };

    $.getJSON = mockjqXHR;
  });

  it('empty state', () => {
    const store = mockStore(emptyState);

    const box = shallow(<Notifications store={store} />);

    expect(toJson(box)).toMatchSnapshot();
  });

  it('should render empty html for state before notifications', () => {
    const store = mockStore(stateWithoutNotifications);

    const box = shallow(<Notifications store={store} />);

    expect(toJson(box)).toMatchSnapshot();
  });

  it('should render full html on a state with notifications', () => {
    const store = mockStore(stateWithNotifications);
    const box = shallow(<Notifications store={store} />);

    expect(toJson(box)).toMatchSnapshot();
  });

  it('should display full bell on a state with unread notifications', () => {
    const store = mockStore(stateWithUnreadNotifications);
    const box = shallow(<Notifications store={store} />);

    expect(box.render().find('.fa-bell').length).toBe(1);
  });

  it('should render a dropdown kebab when links are provided', () => {
    const store = mockStore(stateWithUnreadNotifications);
    const wrapper = shallow(<Notifications store={store} />);

    expect(wrapper.render().find('.dropdown-toggle').length).toBe(1);
  });

  it('full flow', () => {
    const wrapper = mount(
      <Notifications data={componentMountData} store={getStore()} />
    );

    wrapper.find('.fa-bell').simulate('click');
    expect(wrapper.find('.panel-group').length).toEqual(1);
    wrapper.find('.panel-group .panel-heading').simulate('click');
    expect(wrapper.find('.not-seen').length).toEqual(1);
    wrapper.find('.not-seen').simulate('click');
    expect(wrapper.find('.not-seen').length).toEqual(0);
  });

  it('mark group as read flow', () => {
    const wrapper = mount(
      <Notifications data={componentMountData} store={getStore()} />
    );
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
    failResponse = { status: 401 };

    mount(<Notifications data={componentMountData} store={getStore()} />);
    expect(global.location.replace).toBeCalled();
  });

  it('should avoid multiple polling on re-mount', () => {
    const store = getStore();
    const spy = jest.spyOn(API, 'get');

    mount(<Notifications data={componentMountData} store={store} />);
    mount(<Notifications data={componentMountData} store={store} />);

    expect(spy).toHaveBeenCalledTimes(1);
  });

  it('should close the notification box when click the close button', () => {
    const wrapper = mount(
      <Notifications data={componentMountData} store={getStore()} />
    );
    const closeButtonSelector = '.drawer-pf .drawer-pf-title a.drawer-pf-close';

    wrapper.find('.fa-bell').simulate('click');
    expect(toJson(wrapper)).toMatchSnapshot();

    wrapper.find(closeButtonSelector).simulate('click');
    expect(toJson(wrapper)).toMatchSnapshot();
  });

  it('should close the notification box when click outside of the box', () => {
    const wrapper = mount(
      <div>
        <div className="something-outside" />
        <Notifications data={componentMountData} store={getStore()} />
      </div>
    );

    wrapper.find('.fa-bell').simulate('click');
    expect(toJson(wrapper)).toMatchSnapshot();

    wrapper.find('.something-outside').simulate('click');
    expect(toJson(wrapper)).toMatchSnapshot();
  });
});
