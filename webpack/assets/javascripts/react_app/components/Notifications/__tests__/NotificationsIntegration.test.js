import React from 'react';
import { IntegrationTestHelper } from 'react-redux-test-utils';

import Notifications, { reducers } from '../index';

describe('Notifications integration test', () => {
  it('should flow', async () => {
    const integrationTestHelper = new IntegrationTestHelper(reducers);
    const component = integrationTestHelper.mount(<Notifications />);
    component.update();
    /** Create a Flow test */
  });
});
