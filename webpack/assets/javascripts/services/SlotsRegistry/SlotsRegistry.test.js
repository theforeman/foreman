import React from 'react';
import SlotsRegistry from '.';

jest.unmock('./');

const componnentOne = () => <div> Component 1</div>;
const componnentTwo = () => <div> Component 2</div>;
const props = { someProp: true };

describe('Extendable Registry', () => {
  it('should render two components by weights', () => {
    SlotsRegistry.add('slot-id', 'fill-id-1', componnentOne, 100);
    SlotsRegistry.add('slot-id', 'fill-id-2', componnentTwo, 200);
    SlotsRegistry.add('another-slot-id', 'fill-id', props, 300);

    expect(SlotsRegistry.getSlotComponents('slot-id')).toMatchSnapshot();
  });
  it('should render one component after a removal', () => {
    SlotsRegistry.remove('slot-id', 'fill-id-2');
    expect(SlotsRegistry.getSlotComponents('slot-id')).toMatchSnapshot();
  });
});
