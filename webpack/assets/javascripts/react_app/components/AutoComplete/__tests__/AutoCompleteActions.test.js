import API from '../../../API';
import { testActionSnapshotWithFixtures } from '../../../common/testHelpers';
import { getResults, resetData, initialUpdate } from '../AutoCompleteActions';
import {
  APIFailMock,
  APISuccessMock,
  searchQuery,
  controller,
  trigger,
  url,
} from '../AutoComplete.fixtures';

jest.mock('lodash/debounce', () => jest.fn(fn => fn));
jest.mock('../../../API');

const loadResults = (requestParams, serverMock) => {
  API.get.mockImplementation(serverMock);

  return getResults(requestParams);
};

const fixtures = {
  'should update store with initial data': () =>
    initialUpdate('searchQuery', controller),

  'should load results and success': () =>
    loadResults(
      {
        url,
        searchQuery,
        controller,
        trigger,
      },
      async () => APISuccessMock
    ),

  'should load results and fail': () =>
    loadResults(
      {
        url,
        searchQuery: 'x = y',
        controller,
        trigger,
      },
      async () => APIFailMock
    ),

  'should reset-data': () => resetData(controller),
};

describe('AutoComplete actions', () =>
  testActionSnapshotWithFixtures(fixtures));
