import React from '@theforeman/vendor/react';
import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

import NavDropdown from '../components/NavDropdown';

const fixtures = {
  'render NavDropdown': { children: [<li key="key">TEST</li>] },
};

describe('NavDropdown', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(NavDropdown, fixtures));
});
