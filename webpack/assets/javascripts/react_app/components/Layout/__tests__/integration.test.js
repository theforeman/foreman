import React from 'react';
import { BrowserRouter as Router } from 'react-router-dom';

import { IntegrationTestHelper } from '@theforeman/test';

import { hasTaxonomiesMock } from '../Layout.fixtures';
import Layout, { reducers } from '../index';

jest.mock('../../notifications', () => 'span');

describe('Layout integration test', () => {
  it('should flow', async () => {
    const integrationTestHelper = new IntegrationTestHelper(reducers);

    const component = integrationTestHelper.mount(
      <Router>
        <Layout {...hasTaxonomiesMock} />
      </Router>
    );
    await IntegrationTestHelper.flushAllPromises();
    component.update();

    const yamlLocation = component.find('.location_menuitem');
    const org2Organization = component.find('.organization_menuitem');
    const hostsMenuItem = component.find('.secondary-nav-item-pf > a');
    integrationTestHelper.takeStoreSnapshot('initial state');

    yamlLocation.at(0).simulate('click');
    integrationTestHelper.takeStoreAndLastActionSnapshot(
      'Location "yaml" clicked'
    );
    expect(component.find('#location-dropdown > .dropdown-toggle').text()).toBe(
      'yaml'
    );

    await IntegrationTestHelper.flushAllPromises();
    component.update();

    org2Organization.at(1).simulate('click');
    integrationTestHelper.takeStoreAndLastActionSnapshot('Org "org2" clicked');
    expect(
      component.find('#organization-dropdown > .dropdown-toggle').text()
    ).toBe('org2');

    await IntegrationTestHelper.flushAllPromises();
    component.update();

    hostsMenuItem.at(1).simulate('click');
    integrationTestHelper.takeStoreAndLastActionSnapshot(
      'Changed ActiveMenu to Hosts'
    );
    expect(component.find('.secondary-nav-item-pf .active > a').text()).toBe(
      'Hosts'
    );
  });
});
