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
    const dispatcher = actions.markAsRead(21);

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
    const dispatcher = actions.markAsRead(21);

    dispatcher(dispatch, () => state);

    expect(dispatch.mock.calls).toMatchSnapshot();
    expect(API.put.mock.calls).toMatchSnapshot();
  });

  it('should make a notification clear', () => {
    API.put.mockImplementation(async () => null);

    const dispatch = jest.fn();
    const dispatcher = actions.clearNotification(21);

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
});
