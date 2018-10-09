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
import API from '../../../API';
import { mockRequest, mockReset } from '../../../mockRequests';

const middlewares = [thunk];
const mockStore = configureMockStore(middlewares);
const store = mockStore(initialState);

afterEach(() => {
  store.clearActions();
  mockReset();
});

describe('bookmark actions', () => {
  it('should handle failure to load bookmarks', () => {
    const { url, controller, searchRegex } = requestData;

    mockRequest({
      searchRegex,
      status: 422,
    });
    return store
      .dispatch(actions.getBookmarks(url, controller))
      .then(() => expect(store.getActions()).toEqual(onFailureActions));
  });
  it('should load bookmarks', () => {
    const { url, controller, response, searchRegex } = requestData;

    mockRequest({
      searchRegex,
      response,
    });
    return store
      .dispatch(actions.getBookmarks(url, controller))
      .then(() => expect(store.getActions()).toEqual(onSuccessActions));
  });
  it('should load bookmarks with correct search url', () => {
    const { url, controller } = requestData;
    const spy = jest.spyOn(API, 'get');
    const expectedURL = '/api/bookmarks?search=controller%3Dhosts&per_page=100';

    store.dispatch(actions.getBookmarks(url, controller));
    expect(spy).toBeCalledWith(expectedURL);
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
