import React from 'react';
import { BrowserRouter as Router } from 'react-router-dom';

import IntegrationTestHelper from '../../../common/IntegrationTestHelper';

import { hasTaxonomiesMock } from '../Layout.fixtures';
import Layout, { reducers } from '../index';

jest.mock('../../notifications', () => 'span');
describe('Layout integration test', () => {
  it('should flow', async () => {
    const integrationTestHelper = new IntegrationTestHelper(reducers);
    const spy = jest.spyOn(console, 'error').mockImplementation();

    const component = integrationTestHelper.mount(
      <Router>
        <Layout {...hasTaxonomiesMock} />
      </Router>
    );
    await IntegrationTestHelper.flushAllPromises();
    component.update();

    // Currently expect a prop warning since VerticalNav passes an object into NavExpandable title prop although it expects a string. This will change soon.
    expect(spy).toHaveBeenCalledTimes(1);
    // eslint-disable-next-line
    expect(console.error.mock.calls[0][0]).toEqual(expect.stringContaining('Warning: Failed prop type: Invalid prop `title` of type `object` supplied to `NavExpandable`, expected `string`'));
    spy.mockRestore();

    const contextToggles = component.find(
      'button.pf-c-context-selector__toggle'
    );

    // Location
    contextToggles.at(1).simulate('click');
    const yamlLocation = component.find('.location_menuitem');

    integrationTestHelper.takeStoreSnapshot('initial state');

    yamlLocation.at(0).simulate('click');
    integrationTestHelper.takeStoreAndLastActionSnapshot(
      'Location "yaml" clicked'
    );
    expect(
      component
        .find('.pf-c-context-selector__toggle-text')
        .at(1)
        .text()
    ).toBe('yaml');

    await IntegrationTestHelper.flushAllPromises();
    component.update();

    // Organization
    contextToggles.at(0).simulate('click');
    const org2Organization = component.find('.organization_menuitem');
    org2Organization.at(1).simulate('click');
    integrationTestHelper.takeStoreAndLastActionSnapshot('Org "org2" clicked');
    expect(
      component
        .find('.pf-c-context-selector__toggle-text')
        .at(0)
        .text()
    ).toBe('org2');

    const hostsMenuItem = component.find('li.foreman-nav-expandable').at(1);
    hostsMenuItem.prop('onClick')({
      target: {
        getAttribute: attr => 'pf-nav-expandable',
      },
    });

    await IntegrationTestHelper.flushAllPromises();
    hostsMenuItem.update();
    component.update();

    integrationTestHelper.takeStoreAndLastActionSnapshot(
      'Changed ActiveMenu to Hosts'
    );
    expect(
      component
        .find('.pf-c-nav__item.pf-m-expanded > a')
        .at(1)
        .text()
    ).toBe('Hosts');
  });
});
