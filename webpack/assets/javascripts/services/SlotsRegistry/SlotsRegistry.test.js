import React from 'react';
import { add, remove, getSlotComponents } from '.';

jest.unmock('./');

const componnentOne = () => <div> Component 1</div>;
const componnentTwo = () => <div> Component 2</div>;
const props = { someProp: true };

describe('Extendable Registry', () => {
  it('should render two components by weights', () => {
    add('slot-id', 'fill-id-1', componnentOne, 100);
    add('slot-id', 'fill-id-2', componnentTwo, 200);
    add('another-slot-id', 'fill-id', props, 300);

    expect(getSlotComponents('slot-id')).toMatchSnapshot();
  });
  it('should render one component after a removal', () => {
    remove('slot-id', 'fill-id-2');
    expect(getSlotComponents('slot-id')).toMatchSnapshot();
  });
});
