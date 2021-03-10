import { testActionSnapshotWithFixtures } from '../../../common/testHelpers';
import {
  initializeLayout,
  showLoading,
  hideLoading,
  changeActiveMenu,
  collapseLayoutMenus,
  expandLayoutMenus,
} from '../LayoutActions';

const fixtures = {
  'should initialize the layout': () =>
    initializeLayout({
      items: 'some items',
      activeMenu: 'some active menu',
      isCollapsed: false,
      organization: 'org1',
      location: 'loc2',
    }),

  'should showLoading': () => showLoading(),

  'should hideLoading': () => hideLoading(),

  'should changeActiveMenu to Monitor': () =>
    changeActiveMenu({ title: 'Monitor' }),

  'should expandLayoutMenus': () => expandLayoutMenus(),

  'should collapseLayoutMenus': () => collapseLayoutMenus(),
};

describe('Layout actions', () => testActionSnapshotWithFixtures(fixtures));
