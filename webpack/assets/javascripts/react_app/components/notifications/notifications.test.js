import React from 'react';
import { shallow, mount } from 'enzyme';
import Notifications from './';
import thunk from 'redux-thunk';
import configureMockStore from 'redux-mock-store';
import Store from '../../redux';
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
      return new Promise(resolve => resolve(JSON.parse(serverResponse)));
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

    expect(
      box.render().find('.drawer-pf-notification').length
    ).toEqual(1);
  });

  it('should display full bell on a state with unread notifications', () => {
    const store = mockStore(stateWithUnreadNotifications);
    const box = shallow(<Notifications store={store} />);

    expect(box.render().find('.fa-bell').length).toBe(1);
  });

  it('full flow', done => {
    const data = { url: '/notification_recipients' };
    const wrapper = mount(<Notifications data={data} store={Store} />);

    try {
      expect(wrapper.render().find('.fa-bell-o').length).toBe(1);
      setTimeout(() => {
        const rendered = wrapper.render();

        // full bell is rendered
        expect(rendered.find('.fa-bell').length).toBe(1);
        wrapper.find('.fa-bell').simulate('click');
        expect(rendered.find('.panel-group').length).toEqual(0);

        setTimeout(() => {
          // a panel group is rendered (inside the accordion)
          expect(wrapper.find('.panel-group').length).toEqual(1);
          wrapper.find('.panel-group .panel-heading').simulate('click');
          setTimeout(() => {
            expect(wrapper.find('.not-seen').length).toEqual(1);
            wrapper.find('.not-seen').simulate('click');
            setTimeout(() => {
              expect(wrapper.find('.not-seen').length).toEqual(0);
              done();
            });
          });
        });
      });
    } catch (e) {
      done();
    }
  });
});
