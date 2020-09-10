import React from 'react';
import IntegrationTestHelper from '../../../common/IntegrationTestHelper';

import Fill from '../Fill';
import Slot from './';
import FillReducer from '../Fill/FillReducer';

const combinedReducers = { extendable: FillReducer };
const SlotComponent = ({ text }) => <div>{text}</div>; // eslint-disable-line

jest.unmock('../../../../services/SlotsRegistry');

describe('Slot-Fill', () => {
  const integrationTestHelper = new IntegrationTestHelper(combinedReducers);

  it('render multiple fills', () => {
    const FirstComponent = () => <span> Should be the first in the snap</span>;
    const SecondComponent = () => <span> Should be the first in the snap</span>;
    const wrapper = integrationTestHelper.mount(
      <React.Fragment>
        <Fill slotId="slot-1" id="some-key-1" weight={100}>
          <SecondComponent key={1} />
        </Fill>
        <Fill slotId="slot-1" id="some-key-2" weight={200}>
          <FirstComponent key={2} />
        </Fill>

        <Slot id="slot-1" multi>
          <div> defaul value </div>
        </Slot>
      </React.Fragment>
    );

    wrapper.update();
    expect(wrapper.find('Slot')).toMatchSnapshot();
    integrationTestHelper.takeStoreSnapshot();
    integrationTestHelper.takeActionsSnapshot();
  });

  it('Slot with a prop should be pass to a fill', () => {
    const wrapper = integrationTestHelper.mount(
      <React.Fragment>
        <Fill slotId="slot-9" id="some-key-1" weight={100}>
          <SlotComponent key="key" />
        </Fill>

        <Slot id="slot-9" text="this prop should be taken" />
      </React.Fragment>
    );

    wrapper.update();
    expect(wrapper.find('Slot')).toMatchSnapshot();
  });

  it('Fill with no component nor overriden props should throw an error', () => {
    // eslint-disable-next-line no-console
    const err = console.error;
    // eslint-disable-next-line no-console
    console.error = jest.fn();
    expect(() => {
      integrationTestHelper.mount(
        <React.Fragment>
          <Fill slotId="slot-7" id="some-key-1" weight={100} />

          <Slot id="slot-7" />
        </React.Fragment>
      );
    }).toThrowError(new Error('Slot with override props must have a child'));
    // eslint-disable-next-line no-console
    console.error = err;
  });

  it('no multiple fills', () => {
    const AbsentComponent = () => <div> This should not be in the snap </div>;
    const PresentComponent = () => (
      <span> This span should be in the snap </span>
    );
    const wrapper = integrationTestHelper.mount(
      <React.Fragment>
        <Fill slotId="slot-2" id="some-key-1" weight={100}>
          <AbsentComponent key="a" />
        </Fill>
        <Fill slotId="slot-2" id="some-key-1" weight={200}>
          <PresentComponent key="b" />
        </Fill>

        <Slot id="slot-2" multi={false}>
          <div> defaul value </div>
        </Slot>
      </React.Fragment>
    );

    wrapper.update();
    expect(wrapper.find('Slot')).toMatchSnapshot();
  });
  it('props fill', () => {
    const wrapper = integrationTestHelper.mount(
      <React.Fragment>
        <Fill
          overrideProps={{ text: 'This is given by a prop' }}
          slotId="slot-3"
          id="some-key-1"
          weight={100}
        />

        <Slot id="slot-3" multi={false}>
          <SlotComponent key="c" />
        </Slot>
      </React.Fragment>
    );

    wrapper.update();
    expect(wrapper.find('Slot')).toMatchSnapshot();
  });
  it('default slot', () => {
    const wrapper = integrationTestHelper.mount(
      <Slot id="slot-4" multi>
        <SlotComponent text="Default Value" />
      </Slot>
    );

    wrapper.update();
    expect(wrapper.find('Slot')).toMatchSnapshot();
  });
  it('multiple slot with override props', () => {
    const wrapper = integrationTestHelper.mount(
      <React.Fragment>
        <Fill
          overrideProps={{ text: 'This should be the second', key: 1 }}
          slotId="slot-5"
          id="some-key-1"
          weight={100}
        />
        <Fill
          overrideProps={{ text: 'This should be the first', key: 2 }}
          slotId="slot-5"
          id="some-key-2"
          weight={200}
        />
        <Slot id="slot-5" multi>
          <SlotComponent text="Default Value" />
        </Slot>
      </React.Fragment>
    );
    wrapper.update();
    expect(wrapper.find('Slot')).toMatchSnapshot();
  });

  it('slot with multi override props should take max weight', () => {
    const wrapper = integrationTestHelper.mount(
      <React.Fragment>
        <Fill
          overrideProps={{ text: 'This should not be in the snap' }}
          slotId="slot-6"
          id="some-key-1"
          weight={100}
        />
        <Fill
          overrideProps={{
            text: 'This text should be in the snap',
            key: 'textKey',
          }}
          slotId="slot-6"
          id="some-key-2"
          weight={200}
        />
        <Slot id="slot-6">
          <SlotComponent text="Default Value" />
        </Slot>
      </React.Fragment>
    );
    wrapper.update();
    expect(wrapper.find('Slot')).toMatchSnapshot();
  });

  it('multi slot with override props fill and component fill', () => {
    const TestComponent = () => <div> Also this should be in the snap </div>;
    const wrapper = integrationTestHelper.mount(
      <React.Fragment>
        <Fill
          overrideProps={{ key: 'def', text: 'This should be in the snap' }}
          slotId="slot-10"
          id="some-key-1"
          weight={100}
        />
        <Fill slotId="slot-10" id="some-key-2" weight={100}>
          <TestComponent key="abc" />
        </Fill>
        <Slot id="slot-10" multi>
          <SlotComponent text="Default Value" />
        </Slot>
      </React.Fragment>
    );
    wrapper.update();
    expect(wrapper.find('Slot')).toMatchSnapshot();
  });
});
