import React from 'react';
import IntegrationTestHelper from '../../../common/IntegrationTestHelper';
import TypeAheadSelect, { reducers } from './';
import { id, props, options, selected } from './TypeAheadSelect.fixtures';
import { updateOptions, updateSelected } from './TypeAheadSelectActions';

describe('TypeAheadSelect integration test', () => {
  it('flows', async () => {
    const integrationTestHelper = new IntegrationTestHelper(reducers);

    integrationTestHelper.takeStoreSnapshot('initial state');

    const component = integrationTestHelper.mount(
      <TypeAheadSelect {...props} />
    );

    const getProps = wrapper =>
      wrapper
        .find('Typeahead')
        .first()
        .props();

    component.update();

    expect(getProps(component).selected).toEqual(selected);
    expect(getProps(component).options).toEqual(options);

    integrationTestHelper.takeStoreSnapshot('after initialUpdate');

    const newOptions = ['Walrus', 'Bear'];
    const newSelections = ['Bear'];

    integrationTestHelper.store.dispatch(updateOptions(newOptions, id));
    integrationTestHelper.store.dispatch(updateSelected(newSelections, id));
    component.update();

    expect(getProps(component).selected).toEqual(newSelections);
    expect(getProps(component).options).toEqual(newOptions);

    integrationTestHelper.takeStoreSnapshot('updated options and selections');
  });
});
