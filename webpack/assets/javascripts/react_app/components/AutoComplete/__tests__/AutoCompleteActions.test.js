import API from '../../../redux/API/API';
import { testActionSnapshotWithFixtures } from '../../../common/testHelpers';
import {
  getResults,
  resetData,
  initialUpdate,
  updateDisability,
  updateController,
} from '../AutoCompleteActions';
import {
  APIFailMock,
  APISuccessMock,
  searchQuery,
  controller,
  trigger,
  url,
  error,
  id,
  disabled,
} from '../AutoComplete.fixtures';

jest.mock('lodash', () => ({ debounce: jest.fn(fn => fn) }));
jest.mock('../../../redux/API/API');

const loadResults = (requestParams, serverMock) => {
  API.get.mockImplementation(serverMock);

  return getResults(requestParams);
};

const fixtures = {
  'should update store with initial data': () =>
    initialUpdate({ searchQuery, controller, id, disabled, error, url }),

  'should load results and success': () =>
    loadResults(
      {
        url,
        searchQuery,
        controller,
        trigger,
        id,
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
        id,
      },
      async () => APIFailMock
    ),

  'should reset-data': () => resetData(controller, id),

  'should update disability': () => updateDisability(true, id),

  updateController: () => updateController(controller, url, id),
};

describe('AutoComplete actions', () =>
  testActionSnapshotWithFixtures(fixtures));
