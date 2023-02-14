import React from 'react';
import { BrowserRouter as Router } from 'react-router-dom';

import { act } from 'react-dom/test-utils';
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

    const hostsMenuItem = component.find(
      '.pf-c-nav__item.pf-m-flyout > div > div'
    );
    await act(async () => {
      await hostsMenuItem.at(1).simulate('mouseover');
    });
    component.update();
    expect(hostsMenuItem.at(1).text()).toBe('Hosts');
    expect(component.find('.pf-c-menu.pf-m-flyout a').text()).toBe('All Hosts');
  });
});
