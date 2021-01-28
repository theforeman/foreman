import React from 'react';
import { API } from '../../../redux/API';
import IntegrationTestHelper from '../../../common/IntegrationTestHelper';
import { AutoCompleteProps } from '../AutoComplete.fixtures';
import Autocomplete, { reducers } from '../index';

jest.mock('lodash', () => ({
  debounce: jest.fn(fn => fn),
  groupBy: jest.fn((list, getProps) =>
    list.reduce((a, b) => {
      (a[getProps(b)] = a[getProps(b)] || []).push(b);
      return a;
    }, {})
  ),
}));
jest.mock('../../../redux/API');
jest.mock('uuid', () => jest.fn(fn => '1234'));

const combinedReducers = { ...reducers };

describe('Autocomplete integration test', () => {
  it('should flow', async () => {
    const label = 'result';
    API.get.mockImplementation(async () => ({
      data: [{ label, category: '' }],
    }));
    const integrationTestHelper = new IntegrationTestHelper(combinedReducers);
    const wrapper = integrationTestHelper.mount(
      <Autocomplete {...AutoCompleteProps} />
    );
    const AutoCompleteInstance = wrapper.find('AutoComplete').instance();
    const mainInput = wrapper.find('.rbt-input-main').first();
    const menuItemsShouldMatchSecondAPIcall = () => {
      const headers = wrapper.find('.dropdown-header');
      const items = wrapper.find('.dropdown-item');
      const space = ' ';
      expect(headers.at(0).text()).toBe(secondAPICall[0].category);
      expect(items.at(0).text()).toBe(secondAPICall[0].label + space);
      expect(headers.at(1).text()).toBe(secondAPICall[1].category);
      expect(items.at(1).text()).toBe(secondAPICall[1].label + space);
    };

    integrationTestHelper.takeStoreSnapshot('initial state');
    // Trigger Focus
    mainInput.simulate('focus', { target: { value: '' } });
    integrationTestHelper.takeStoreAndLastActionSnapshot('input focused');
    // Because request status is PENDING, check if the loading spinner exists.
    expect(wrapper.find('.rbt-loader').exists()).toBeTruthy();
    await IntegrationTestHelper.flushAllPromises();
    wrapper.update();
    integrationTestHelper.takeStoreAndLastActionSnapshot(
      'request that was triggered by focus is over'
    );
    // Because request status is not PENDING, check if the loading spinner disappeared.
    expect(wrapper.find('.rbt-loader').exists()).toBeFalsy();
    // Trigger Focus
    mainInput.simulate('focus', { target: { value: '' } });
    // The menu should be visible
    expect(wrapper.find('.rbt-menu').exists()).toBeTruthy();
    const menuItem = wrapper.find('.dropdown-item').first();
    // The label of the menuItem should be the same as the label returned from our mocked API.
    expect(menuItem.text()).toBe(label);
    // Set a new mocked API response
    const secondAPICall = [
      { label: 'results1', category: '' },
      { label: 'results2', category: 'Dolphin' },
    ];
    API.get.mockImplementation(async () => ({ data: secondAPICall }));
    // Choose an option.
    menuItem.simulate('click');
    integrationTestHelper.takeStoreAndLastActionSnapshot('option selected');
    await IntegrationTestHelper.flushAllPromises();
    wrapper.update();
    integrationTestHelper.takeStoreAndLastActionSnapshot(
      'request that was triggered by option select is over'
    );
    // expect input text to be the same as the selected option(label).
    expect(AutoCompleteInstance.props.searchQuery).toBe(label);
    // expect menu to be open and to be built correctly
    menuItemsShouldMatchSecondAPIcall();
    // Simulate clear
    wrapper
      .find('.autocomplete-clear-button')
      .first()
      .simulate('click');
    integrationTestHelper.takeStoreAndLastActionSnapshot(
      'Clear button clicked'
    );
    // Because it detects that it was searched earlier, no API request will be made,
    // and menu items should be the first menu Items.
    expect(menuItem.text()).toBe(label);
    // trigger menu item click.
    menuItem.simulate('click');
    integrationTestHelper.takeStoreAndLastActionSnapshot(
      'option selected again'
    );
    // same request as before, no need of another API request.
    // menu items should be the same as in the second API call.
    menuItemsShouldMatchSecondAPIcall();
  });
});
