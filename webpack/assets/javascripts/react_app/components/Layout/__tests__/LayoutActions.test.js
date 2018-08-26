import { testActionSnapshotWithFixtures } from '../../../common/testHelpers';
import { showLoading, hideLoading, changeActiveMenu, fetchMenuItems, changeOrganization, changeLocation } from '../LayoutActions';

import { layoutMock, serverItems } from '../Layout.fixtures';

const runChangeActiveMenu = () => (dispatch) => {
  const getState = () => ({
    layout: {
      items: serverItems,
    },
  });
  changeActiveMenu({ title: 'Monitor' })(dispatch, getState);
};

const fixtures = {
  'should showLoading': () => showLoading(),

  'should hideLoading': () => hideLoading(),

  'should changeActiveMenu to Monitor': () => runChangeActiveMenu(),

  'should fetchMenuItems': () => fetchMenuItems(layoutMock.data),

  'should changeOrganization': () => changeOrganization('org1'),

  'should changeLocation': () => changeLocation('loc1'),
};

describe('Layout actions', () => testActionSnapshotWithFixtures(fixtures));

