import toJson from 'enzyme-to-json';
import React from 'react';

import IntegrationTestHelper from '../../../common/IntegrationTestHelper';
import Fill from '../Fill';
import Slot from './';
import FillReducer from '../Fill/FillReducer';

const combinedReducers = { extendable: FillReducer };
const SlotComponent = ({ text }) => <div>{text}</div>;

describe('Slot-Fill', () => {
  const integrationTestHelper = new IntegrationTestHelper(combinedReducers);

  it('multiple fills', () => {
    const wrapper = integrationTestHelper.mount(
      <React.Fragment>
        <Fill id="slot-1" fillId="some-key-1" weight={100}>
          <div> Extendable component 1 </div>
        </Fill>
        <Fill id="slot-1" fillId="some-key-2" weight={200}>
          <span> Extendable component 2 </span>
        </Fill>

        <Slot id="slot-1" multi>
          <div> defaul value </div>
        </Slot>
      </React.Fragment>
    );

    wrapper.update();
    expect(toJson(wrapper.find('Slot'))).toMatchSnapshot();
  });
  it('no nultiple fills', () => {
    const wrapper = integrationTestHelper.mount(
      <React.Fragment>
        <Fill id="slot-2" fillId="some-key-1" weight={100}>
          <div> Extendable component 1 </div>
        </Fill>
        <Fill id="slot-2" fillId="some-key-1" weight={200}>
          <span> Extendable component 2 </span>
        </Fill>

        <Slot id="slot-2" multi={false}>
          <div> defaul value </div>
        </Slot>
      </React.Fragment>
    );

    wrapper.update();
    expect(toJson(wrapper.find('Slot'))).toMatchSnapshot();
  });
  it('props fill', () => {
    const wrapper = integrationTestHelper.mount(
      <React.Fragment>
        <Fill
          overrideProps={{ text: 'This is given by a prop' }}
          id="slot-3"
          fillId="some-key-1"
          weight={100}
        />

        <Slot id="slot-3" multi={false}>
          <SlotComponent />
        </Slot>
      </React.Fragment>
    );

    wrapper.update();
    expect(toJson(wrapper.find('Slot'))).toMatchSnapshot();
  });
  it('default slot', () => {
    const wrapper = integrationTestHelper.mount(
      <Slot id="slot-4" multi>
        <SlotComponent text="Default Value" />
      </Slot>
    );

    wrapper.update();
    expect(toJson(wrapper.find('Slot'))).toMatchSnapshot();
  });
  it('multiple slot should be forbidden when override props', () => {
    const wrapper = expect(
      integrationTestHelper
        .mount(
          <React.Fragment>
            <Fill
              overridProps={{ text: 'This is given by a prop' }}
              id="slot-5"
              fillId="some-key-1"
              weight={100}
            />
            <Fill
              overridProps={{ text: 'This is given by a prop' }}
              id="slot-5"
              fillId="some-key-2"
              weight={200}
            />
            <Slot id="slot-5" multi>
              <SlotComponent text="Default Value" />
            </Slot>
          </React.Fragment>
        )
        .toThrowError(new Error())
    );
  });
});
