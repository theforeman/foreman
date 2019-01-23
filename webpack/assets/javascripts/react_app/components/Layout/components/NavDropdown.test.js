import React from 'react';
import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';

import NavDropdown from '../components/NavDropdown';

const fixtures = {
  'render NavDropdown': { children: [<li key="key">TEST</li>] },
};

describe('NavDropdown', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(NavDropdown, fixtures));
});
