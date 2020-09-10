import React from 'react';

import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import RedirectCancelButton from './RedirectCancelButton';

jest.mock('../../../common/withReactRoutes', () => Component => props => (
  <div className="component-with-mocked-routes">
    <Component {...props} />
  </div>
));

const fixtures = {
  'renders correctly': { cancelPath: '/hosts' },
};

describe('RedirectCancelButton', () =>
  testComponentSnapshotsWithFixtures(RedirectCancelButton, fixtures));
