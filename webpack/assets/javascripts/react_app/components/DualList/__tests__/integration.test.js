import React from 'react';
import IntegrationTestHelper from '../../../common/IntegrationTestHelper';
import { props } from '../DualList.fixtures';
import Duallist, { reducers } from '../index';

const combinedReducers = { ...reducers };

describe('Duallist integration test', () => {
  it('should flow', async () => {
    const integrationTestHelper = new IntegrationTestHelper(combinedReducers);
    const component = integrationTestHelper.mount(<Duallist {...props} />);
    integrationTestHelper.takeStoreSnapshot('initial state');
    const selectors = component.find('DualListSelector');
    const firstItemCheckbox = selectors
      .first()
      .find('label.dual-list-pf-item > input[type="checkbox"]')
      .first();
    const arrows = component.find('DualListArrows').find('Icon');
    const rightArrow = arrows.at(0);
    const {
      'data-side': side,
      'data-position': position,
    } = firstItemCheckbox.props();
    const mockedEvent = {
      target: { checked: true, dataset: { position, side } },
    };
    firstItemCheckbox.simulate('change', mockedEvent);
    rightArrow.simulate('click');
    integrationTestHelper.takeStoreSnapshot('transitions between lists');
  });
});
