import React from 'react';
import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

import LayoutContainer from './LayoutContainer';

const fixtures = {
  'render LayoutContainer': {
    isCollapsed: false,
    children: [<li key="key">TEST</li>],
  },
  'render LayoutContainer w/Collapsed Nav': {
    isCollapsed: true,
    children: [<li key="key">TEST</li>],
  },
};

describe('LayoutContainer', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(LayoutContainer, fixtures));
});
