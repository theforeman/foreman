import React from 'react';
import { Overlay } from 'patternfly-react';

import API from '../../../redux/API/API';
import IntegrationTestHelper from '../../../common/IntegrationTestHelper';

import {
  breadcrumbBarSwithcable,
  serverResourceListResponse,
} from '../BreadcrumbBar.fixtures';
import BreadcrumbBar, { reducers } from '../index';

jest.mock('../../../redux/API/API');

describe('BreadcrumbBar integration test', () => {
  it('should flow', async () => {
    API.get.mockImplementation(async () => serverResourceListResponse);

    const integrationTestHelper = new IntegrationTestHelper(reducers);

    const component = integrationTestHelper.mount(
      <BreadcrumbBar {...breadcrumbBarSwithcable} />
    );
    const togglerButton = component.find('.breadcrumb-switcher .btn');

    integrationTestHelper.takeStoreSnapshot('initial state');

    togglerButton.simulate('click');
    integrationTestHelper.takeStoreAndLastActionSnapshot('switcher opened');
    expect(
      component
        .find(
          '#breadcrumb-switcher-popover .breadcrumb-switcher-popover-loading'
        )
        .exists()
    ).toBeTruthy();
    expect(
      component.find('#breadcrumb-switcher-popover .scrollable-list').exists()
    ).not.toBeTruthy();

    await IntegrationTestHelper.flushAllPromises();
    component.update();
    integrationTestHelper.takeStoreAndLastActionSnapshot(
      'switcher opened and loaded'
    );
    expect(
      component
        .find(
          '#breadcrumb-switcher-popover .breadcrumb-switcher-popover-loading'
        )
        .exists()
    ).not.toBeTruthy();
    expect(
      component.find('#breadcrumb-switcher-popover .scrollable-list').exists()
    ).toBeTruthy();

    API.get.mockImplementation(async () => ({
      data: { ...serverResourceListResponse.data, page: 2 },
    }));
    component.find('.pager .next a').simulate('click');
    await IntegrationTestHelper.flushAllPromises();
    component.update();
    integrationTestHelper.takeStoreAndLastActionSnapshot(
      'switcher after next page'
    );

    API.get.mockImplementation(async () => serverResourceListResponse);
    component.find('.pager .previous a').simulate('click');
    await IntegrationTestHelper.flushAllPromises();
    component.update();
    integrationTestHelper.takeStoreAndLastActionSnapshot(
      'switcher after prev page'
    );

    component.find('input').simulate('change', { target: { value: 'text' } });
    await IntegrationTestHelper.flushAllPromises();
    integrationTestHelper.takeStoreAndLastActionSnapshot(
      'switcher after search change'
    );
    expect(component.find('input').props().value).toBe('text');

    component.find('.fa-close').simulate('click');
    await IntegrationTestHelper.flushAllPromises();
    component.update();
    expect(component.find('input').props().value).toBe('');
    integrationTestHelper.takeStoreAndLastActionSnapshot(
      'switcher after search clear '
    );

    togglerButton.simulate('click');
    integrationTestHelper.takeStoreAndLastActionSnapshot('switcher closed');
    expect(component.find(Overlay).props().show).not.toBeTruthy();
  });
});
