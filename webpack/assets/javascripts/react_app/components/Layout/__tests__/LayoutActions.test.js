import { testActionSnapshotWithFixtures } from '../../../common/testHelpers';
import {
  showLoading,
  hideLoading,
  changeActiveMenu,
  fetchMenuItems,
  changeOrganization,
  changeLocation,
  onCollapse,
  onExpand,
} from '../LayoutActions';

import { layoutMock } from '../Layout.fixtures';

const fixtures = {
  'should showLoading': () => showLoading(),

  'should hideLoading': () => hideLoading(),

  'should changeActiveMenu to Monitor': () =>
    changeActiveMenu({ title: 'Monitor' }),
  'should onExpand': () => onExpand(),

  'should onCollapse': () => onCollapse(),

  'should fetchMenuItems': () => fetchMenuItems(layoutMock.data),

  'should changeOrganization': () => changeOrganization('org1'),

  'should changeLocation': () => changeLocation('loc1'),
};

describe('Layout actions', () => testActionSnapshotWithFixtures(fixtures));
