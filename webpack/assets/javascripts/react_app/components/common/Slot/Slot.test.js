import React from 'react';
import '@testing-library/jest-dom';
import { screen } from '@testing-library/react';
import Fill from '../Fill';
import Slot from './';
import { rtlHelpers } from '../../../common/rtlTestHelpers';

const { renderWithStore } = rtlHelpers;
const SlotComponent = ({ text }) => <div>{text}</div>; // eslint-disable-line

jest.unmock('../../../../services/SlotsRegistry');

describe('Slot-Fill', () => {
  it('Slot with a prop should be passed to a fill', async () => {
    renderWithStore(
      <React.Fragment>
        <Fill slotId="slot-9" id="some-key-1" weight={100}>
          <SlotComponent key="key" />
        </Fill>
        <Slot id="slot-9" text="this prop should be taken" />
      </React.Fragment>
    );

    expect(await screen.findByText('this prop should be taken')).toBeInTheDocument();
  });

  it('Fill with no component nor overriden props should throw an error', () => {
    // eslint-disable-next-line no-console
    const err = console.error;
    // eslint-disable-next-line no-console
    console.error = jest.fn();
    expect(() => {
      renderWithStore(
        <React.Fragment>
          <Fill slotId="slot-7" id="some-key-1" weight={100} />

          <Slot id="slot-7" />
        </React.Fragment>
      );
    }).toThrowError(new Error('Slot with override props must have a child'));

    // eslint-disable-next-line no-console
    console.error = err;
  });

  it('no multiple fills', async () => {
    const AbsentComponent = () => <div>This should not be in the snap</div>;
    const PresentComponent = () => (
      <span>This span should be in the snap</span>
    );

    renderWithStore(
      <React.Fragment>
        <Fill slotId="slot-2" id="some-key-1" weight={100}>
          <AbsentComponent key="a" />
        </Fill>
        <Fill slotId="slot-2" id="some-key-1" weight={200}>
          <PresentComponent key="b" />
        </Fill>
        <Slot id="slot-2" multi={false}>
          <div>default value</div>
        </Slot>
      </React.Fragment>
    );

    expect(await screen.findByText('This span should be in the snap')).toBeInTheDocument();

    expect(screen.queryByText('This should not be in the snap')).not.toBeInTheDocument();
  });

  it('props fill', async () => {
    renderWithStore(
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

    expect(await screen.findByText('This is given by a prop')).toBeInTheDocument();
  });

  it('default slot', () => {
    renderWithStore(
      <Slot id="slot-4" multi>
        <SlotComponent text="Default Value" />
      </Slot>
    );

    expect(screen.getByText('Default Value')).toBeInTheDocument();
  });

  it('multiple slot with override props', async () => {
    renderWithStore(
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
    const e1 = await screen.findByText('This should be the first');
    const e2 = await screen.findByText('This should be the second');
    expect(e1.compareDocumentPosition(e2)).toBe(4);
  });

  it('slot with multi override props should take max weight', async () => {
    renderWithStore(
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

    expect(await screen.findByText('This text should be in the snap')).toBeInTheDocument();

    expect(screen.queryByText('This should not be in the snap')).not.toBeInTheDocument();
  });

  it('multi slot with override props fill and component fill', async () => {
    const TestComponent = () => <div>Also this should be in the snap</div>;
    renderWithStore(
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

    expect(await screen.findByText('This should be in the snap')).toBeInTheDocument();
    expect(await screen.findByText('Also this should be in the snap')).toBeInTheDocument();
  });
});
