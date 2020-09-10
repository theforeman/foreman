import { testSelectorsSnapshotWithFixtures } from '@theforeman/test';

import {
  selectModels,
  selectPage,
  selectPerPage,
  selectSearch,
  selectSort,
  selectHasData,
  selectHasError,
  selectIsLoading,
  selectSubtotal,
  selectMessage,
} from '../ModelsPageSelectors';

import { stateFactory, models } from './ModelsPage.fixtures';

const state = stateFactory({
  results: models,
  sort: { by: 'name', order: 'DESC' },
  page: 1,
  perPage: 1,
  search: 'name ~ foo',
  subtotal: 42,
  message: { type: 'error', text: 'This is error' },
});

const fixtures = {
  'should return models': () => selectModels(state),
  'should return page': () => selectPage(state),
  'should return perPage': () => selectPerPage(state),
  'should return search': () => selectSearch(state),
  'should return sort': () => selectSort(state),
  'should return hasData': () => selectHasData(state),
  'should return hasError': () => selectHasError(state),
  'should return isLoading': () => selectIsLoading(state),
  'should return subtotal': () => selectSubtotal(state),
  'should return message': () => selectMessage(state),
};

describe('ModelsPage selectors', () =>
  testSelectorsSnapshotWithFixtures(fixtures));
