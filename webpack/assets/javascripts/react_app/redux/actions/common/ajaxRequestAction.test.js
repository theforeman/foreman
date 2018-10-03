import { ajaxRequestAction } from './';
import API from '../../../API';

const data = { results: [1] };

const item = { name: 'test', id: 'myid' };
const requestAction = 'REQUEST';
const successAction = 'SUCCESS';
const failedAction = 'FAILURE';

describe('ajaxRequestAction', () => {
  const setup = (dispatch, actionKey, actionValue) =>
    ajaxRequestAction({
      dispatch,
      [actionKey]: actionValue,
      requestAction,
      item,
    }).then(() => expect(dispatch.mock.calls).toMatchSnapshot());

  let dispatch;
  beforeEach(() => {
    dispatch = jest.fn();
  });
  it('should dispatch request action first', () => {
    const url = 'hosts/host1/memory';
    ajaxRequestAction({
      dispatch,
      requestAction,
      item,
      url,
    });
    expect(dispatch).toBeCalledWith({ type: requestAction, payload: item });
  });
  it('should dispatch request and success actions on resolve', () => {
    API.get = jest.fn(
      url =>
        new Promise((resolve, reject) => {
          resolve({ data });
        })
    );
    return setup(dispatch, 'successAction', successAction);
  });

  it('should dispatch request and failure actions on reject', () => {
    API.get = jest.fn(
      url =>
        new Promise((resolve, reject) => {
          reject(Error('bad request'));
        })
    );
    return setup(dispatch, 'failedAction', failedAction);
  });
});
