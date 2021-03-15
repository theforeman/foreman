import React from 'react';
import { BrowserRouter as Router } from 'react-router-dom';

import { IntegrationTestHelper } from '@theforeman/test';

import { hasTaxonomiesMock } from '../Layout.fixtures';
import Layout, { reducers } from '../index';
import ForemanContext from '../../../Root/Context/ForemanContext';

jest.mock('../../notifications', () => 'span');

// mock the taxonomy context to match the test until we implement context setter

jest
  .spyOn(ForemanContext, 'useForemanLocation')
  .mockReturnValue({ title: 'london' });
jest
  .spyOn(ForemanContext, 'useForemanOrganization')
  .mockReturnValue({ title: 'org1' });

afterEach(() => {
  jest.clearAllMocks();
});
describe('Layout integration test', () => {
  it('should flow', async () => {
    const integrationTestHelper = new IntegrationTestHelper(reducers);
    Object.defineProperty(window, 'location', {
      writable: true,
      value: { assign: jest.fn(), pathname: '/' },
    });
    const component = integrationTestHelper.mount(
      <Router>
        <Layout {...hasTaxonomiesMock} />
      </Router>
    );
    await IntegrationTestHelper.flushAllPromises();
    component.update();

    integrationTestHelper.takeStoreSnapshot('initial state');
    expect(
      component
        .find('#location-dropdown .pf-c-context-selector__toggle-text')
        .text()
    ).toBe('london');
    expect(
      component
        .find('#organization-dropdown .pf-c-context-selector__toggle-text')
        .text()
    ).toBe('org1');

    const hostsMenuItem = component.find('.secondary-nav-item-pf > a');

    hostsMenuItem.at(1).simulate('click');
    integrationTestHelper.takeStoreAndLastActionSnapshot(
      'Changed ActiveMenu to Hosts'
    );
    expect(component.find('.secondary-nav-item-pf .active > a').text()).toBe(
      'Hosts'
    );
  });
});
