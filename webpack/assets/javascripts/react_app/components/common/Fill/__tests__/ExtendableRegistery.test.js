import React from 'react';
import { add, remove, getComponentsBySlotId } from '../ExtendableRegistery';

jest.unmock('lodash');
jest.unmock('../ExtendableRegistery');

const componnentOne = () => <div> Component 1</div>;
const componnentTwo = () => <div> Component 2</div>;
const props = { someProp: true };

describe('Extendable Registery', () => {
  it('should render two components by weights', () => {
    add('slot-id', 'fill-id-1', componnentOne, 100);
    add('slot-id', 'fill-id-2', componnentTwo, 200);
    add('another-slot-id', 'fill-id', props, 300);

    expect(getComponentsBySlotId('slot-id')).toMatchSnapshot();
  });
  it('should render one component after a removal', () => {
    remove('slot-id', 'fill-id-2');
    expect(getComponentsBySlotId('slot-id')).toMatchSnapshot();
  });
});
