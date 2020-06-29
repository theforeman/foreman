import { API } from '../../../redux/API';
import * as actions from './index';

jest.mock('../../../redux/API/API');

describe('Notification Drawer actions', () => {
  it('should make notification group read', () => {
    API.put.mockImplementation(async () => null);

    const dispatch = jest.fn();
    const dispatcher = actions.markGroupAsRead('Community');

    dispatcher(dispatch);

    expect(dispatch.mock.calls).toMatchSnapshot();
    expect(API.put.mock.calls).toMatchSnapshot();
  });

  it('should make a notification read', () => {
    API.put.mockImplementation(async () => null);
    const state = {
      notifications: {
        expandedGroup: 'Community',
        notifications: [{ id: 21, seen: false }],
      },
    };
    const dispatch = jest.fn();
    const dispatcher = actions.markAsRead('Community', 21);

    dispatcher(dispatch, () => state);

    expect(dispatch.mock.calls).toMatchSnapshot();
    expect(API.put.mock.calls).toMatchSnapshot();
  });

  it('should skip a notification read', () => {
    API.put.mockImplementation(async () => null);
    const state = {
      notifications: {
        expandedGroup: 'Community',
        notifications: [{ id: 21, seen: true }],
      },
    };
    const dispatch = jest.fn();
    const dispatcher = actions.markAsRead('Community', 21);

    dispatcher(dispatch, () => state);

    expect(dispatch.mock.calls).toMatchSnapshot();
    expect(API.put.mock.calls).toMatchSnapshot();
  });

  it('should make a notification clear', () => {
    API.put.mockImplementation(async () => null);

    const dispatch = jest.fn();
    const dispatcher = actions.clearNotification('Community', 21);

    dispatcher(dispatch);

    expect(dispatch.mock.calls).toMatchSnapshot();
    expect(API.put.mock.calls).toMatchSnapshot();
  });

  it('should make a group clear', () => {
    API.put.mockImplementation(async () => null);

    const dispatch = jest.fn();
    const dispatcher = actions.clearGroup('Community');

    dispatcher(dispatch);

    expect(dispatch.mock.calls).toMatchSnapshot();
    expect(API.put.mock.calls).toMatchSnapshot();
  });

  it('should expand different group', () => {
    const state = { notifications: { expandedGroup: 'Hosts' } };
    const dispatch = jest.fn();
    const dispatcher = actions.expandGroup('Community');

    dispatcher(dispatch, () => state);

    expect(dispatch.mock.calls).toMatchSnapshot();
  });

  it('should expand same group', () => {
    const state = { notifications: { expandedGroup: 'Community' } };
    const dispatch = jest.fn();
    const dispatcher = actions.expandGroup('Community');

    dispatcher(dispatch, () => state);

    expect(dispatch.mock.calls).toMatchSnapshot();
  });

  it('should toggle closed drawer', () => {
    const state = { notifications: { isDrawerOpen: false } };
    const dispatch = jest.fn();
    const dispatcher = actions.toggleDrawer();

    dispatcher(dispatch, () => state);

    expect(dispatch.mock.calls).toMatchSnapshot();
  });

  it('should toggle opened drawer', () => {
    const state = { notifications: { isDrawerOpen: true } };
    const dispatch = jest.fn();
    const dispatcher = actions.toggleDrawer();

    dispatcher(dispatch, () => state);

    expect(dispatch.mock.calls).toMatchSnapshot();
  });

  it('should open link', () => {
    const opener = 'original-opener';
    global.open = () => ({ opener });

    const toggleDrawerAction = () => 'toggle the drawer action';

    const dispatch = jest.fn();
    const dispatcher = actions.clickedLink(
      { href: 'https://www.redhat.com/en' },
      toggleDrawerAction
    );

    const openedWindow = dispatcher(dispatch);

    expect(openedWindow.opener).toEqual(opener);
    expect(dispatch.mock.calls).toMatchSnapshot();
  });

  it('should open external link', () => {
    const opener = 'original-opener';
    global.open = () => ({ opener });

    const toggleDrawerAction = () => 'toggle the drawer action';

    const dispatch = jest.fn();
    const dispatcher = actions.clickedLink(
      {
        href: 'https://www.redhat.com/en',
        external: true,
      },
      toggleDrawerAction
    );

    const openedWindow = dispatcher(dispatch);

    expect(openedWindow.opener).toBe(null);
    expect(dispatch.mock.calls).toMatchSnapshot();
  });
});
