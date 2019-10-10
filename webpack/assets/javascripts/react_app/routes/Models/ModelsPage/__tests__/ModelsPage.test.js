import { testComponentSnapshotsWithFixtures } from '@theforeman/test';
import ModelsPage from '../ModelsPage';
import { propsFactory, models } from './ModelsPage.fixtures';

const props = {
  fetchAndPush: () => {},
  models,
  itemCount: models.length,
  canCreate: true,
};

const fixtures = {
  'should render when loading': propsFactory({
    ...props,
    isLoading: true,
    hasData: false,
    hasError: false,
    toasts: [],
  }),
  'should render with no data': propsFactory({
    ...props,
    isLoading: false,
    hasData: false,
    hasError: false,
    toasts: [],
  }),
  'should render with error': propsFactory({
    isLoading: false,
    hasData: false,
    hasError: true,
    message: {
      type: 'error',
      text: 'this is error',
    },
    ...props,
    toasts: [],
  }),
  'should render with models': propsFactory({
    ...props,
    isLoading: false,
    hasError: false,
    hasData: true,
    toasts: [],
  }),
};

describe('ModelsPage', () => {
  describe('redering', () =>
    testComponentSnapshotsWithFixtures(ModelsPage, fixtures));
});
