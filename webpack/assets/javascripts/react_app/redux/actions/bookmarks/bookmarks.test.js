/* eslint-disable promise/prefer-await-to-then */
import configureMockStore from 'redux-mock-store';
import thunk from 'redux-thunk';
import * as actions from './index';
import * as types from '../../consts';
import {
  initialState,
  requestData,
  onFailureActions,
  onSuccessActions,
} from './bookmarks.fixtures';
import API from '../../API/API';
import { APIMiddleware } from '../../API';
import IntegrationTestHelper from '../../../common/IntegrationTestHelper';

const middlewares = [thunk, APIMiddleware];
const mockStore = configureMockStore(middlewares);
const store = mockStore(initialState);

jest.mock('../../API/API');
afterEach(() => {
  store.clearActions();
});

describe('bookmark actions', () => {
  it('should handle failure to load bookmarks', async () => {
    API.get.mockImplementationOnce(
      url =>
        new Promise((resolve, reject) => {
          reject(Error('Request failed with status code 422'));
        })
    );
    const { url, controller } = requestData;
    await store.dispatch(actions.getBookmarks(url, controller));
    await IntegrationTestHelper.flushAllPromises();

    expect(store.getActions()).toEqual(onFailureActions);
  });
  it('should load bookmarks', async () => {
    const { url, controller, response } = requestData;
    API.get.mockImplementation(
      urlAPI =>
        new Promise((resolve, reject) => {
          resolve({ data: response });
        })
    );
    store.dispatch(actions.getBookmarks(url, controller));
    await IntegrationTestHelper.flushAllPromises();

    expect(store.getActions()).toEqual(onSuccessActions);
  });
  it('should load bookmarks with correct search url', () => {
    const { url, controller } = requestData;
    const spy = jest.spyOn(API, 'get');
    const expectedURL = '/api/bookmarks?search=controller%3Dhosts&per_page=100';

    store.dispatch(actions.getBookmarks(url, controller));
    expect(spy).toBeCalledWith(expectedURL, {}, {});
  });
  it('should open modal with current search query in action payload', () => {
    const query = 'some search query';
    const expectedAction = {
      type: types.BOOKMARKS_MODAL_OPENED,
      payload: { query },
    };

    expect(actions.modalOpened(query)).toEqual(expectedAction);
  });
});
