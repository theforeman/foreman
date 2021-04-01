import { testActionSnapshotWithFixtures } from '../../../common/testHelpers';
import {
  initializeLayout,
  showLoading,
  hideLoading,
  changeIsNavOpen,
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

  'should changeIsNavOpen': () => changeIsNavOpen(false),

};

describe('Layout actions', () => testActionSnapshotWithFixtures(fixtures));
