import { testActionSnapshotWithFixtures } from '../../../common/testHelpers';
import {
  initializeLayout,
  showLoading,
  hideLoading,
} from '../LayoutActions';

const fixtures = {
  'should initialize the layout': () =>
    initializeLayout({
      items: 'some items',
      organization: 'org1',
      location: 'loc2',
    }),

  'should showLoading': () => showLoading(),

  'should hideLoading': () => hideLoading(),
};

describe('Layout actions', () => testActionSnapshotWithFixtures(fixtures));
