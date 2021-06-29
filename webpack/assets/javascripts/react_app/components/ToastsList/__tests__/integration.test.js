import React from 'react';
import IntegrationTestHelper from '../../../common/IntegrationTestHelper';

import ToastsList from '../index'
import * as selectors from '../ToastsListSelectors'
import { spySelector } from './fixtures'

spySelector(selectors);

describe('ToastList', () => {
  it('integration', () => {
    const integrationTestHelper = new IntegrationTestHelper({});
    const component = integrationTestHelper.mount(<ToastsList />);
    const alerts = component.find('.pf-c-alert.foreman-toast')

    expect(alerts.length).toBe(1);
    expect(component.find('.pf-c-alert__title').at(0).text()).toBe('Success alert:message');
  });
});
