import configureMockStore from 'redux-mock-store';
import thunk from 'redux-thunk';
import $ from 'jquery';
import * as actions from './index';
import * as types from '../../consts';
import {
  initialState,
  requestData,
  onFailureActions,
  onSuccessActions,
} from './bookmarks.fixtures';
import { bookmarks } from '../../reducers/bookmarks/bookmarks.fixtures';
import API from '../../../API';

const middlewares = [thunk];
const mockStore = configureMockStore(middlewares);

describe('bookmark actions', () => {
  it('should handle failure to load bookmarks', () => {
    const store = mockStore(initialState);
    const { url, controller } = requestData;

    store.dispatch(actions.getBookmarks(url, controller));
    expect(store.getActions()).toEqual(onFailureActions);
  });
  xit('should load bookmarks', () => {
    const store = mockStore(initialState);
    const { url, controller } = requestData;

    $.ajax = jest.fn(() => {
      const ajaxMock = $.Deferred();

      ajaxMock.resolve({ results: bookmarks });
      return ajaxMock.promise();
    });

    store.dispatch(actions.getBookmarks(url, controller));
    expect(store.getActions()).toEqual(onSuccessActions);
  });
  it('should load bookmarks with correct search url', () => {
    const store = mockStore(initialState);
    const { url, controller } = requestData;
    const spy = jest.spyOn(API, 'get');
    const expectedURL = '/api/bookmarks?search=controller%3Dhosts&per_page=100';

    store.dispatch(actions.getBookmarks(url, controller));
    expect(spy).toBeCalledWith(expectedURL);
  });
  it('should open modal with current search query in action payload', () => {
    document.body.innerHTML =
      '<input type="text" name="search" id="search" value="some search query" />';

    const expectedAction = {
      type: types.BOOKMARKS_MODAL_OPENED,
      payload: { query: 'some search query' },
    };

    expect(actions.modalOpened()).toEqual(expectedAction);
  });
});
