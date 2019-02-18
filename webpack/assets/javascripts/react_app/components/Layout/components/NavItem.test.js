import React from '@theforeman/vendor/react';
import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

import NavItem from '../components/NavItem';

const fixtures = {
  'render NavItem': { children: [<li key="key">TEST</li>] },
};

describe('NavItem', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(NavItem, fixtures));
});
