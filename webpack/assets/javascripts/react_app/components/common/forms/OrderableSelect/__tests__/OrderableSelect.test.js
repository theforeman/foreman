import React from 'react';
import { act } from 'react-dom/test-utils';
import { DragDropContext } from 'react-dnd';
import TestBackend from 'react-dnd-test-backend';
import { mount } from 'enzyme';

import OrderableSelect from '../OrderableSelect';
import { yesNoOpts } from '../../__fixtures__/Form.fixtures';

const WrapedInTestContext = DragDropContext(TestBackend)(OrderableSelect);

describe('OrderableSelect', () => {
  it('reorders the selected value by dragging', () => {
    let selected;
    const wrapper = mount(
      <WrapedInTestContext
        id="testOrderable"
        options={yesNoOpts}
        value={['yes', 'no', 'dnk']}
      />
    );
    const manager = wrapper.instance().getManager();
    const backend = manager.getBackend();
    const monitor = manager.getMonitor();
    const source = wrapper
      .find('#testOrderable-dnk')
      .find('DragSource(Orderable(OrderableToken))');
    const target = wrapper
      .find('#testOrderable-no')
      .find('DropTarget(DragSource(Orderable(OrderableToken)))');
    // hack the client mouse offset
    monitor.getClientOffset = jest.fn(() => ({ x: 0, y: 0 }));

    expect(source).toHaveLength(1);
    expect(target).toHaveLength(1);

    selected = wrapper.find('Typeahead').prop('selected');
    expect(selected[1].value).toBe('no');
    expect(selected[2].value).toBe('dnk');

    act(() => {
      backend.simulateBeginDrag([source.instance().getHandlerId()]);
      backend.simulateHover([target.instance().getHandlerId()]);
      backend.simulateDrop();
      backend.simulateEndDrag();
    });

    // rerender as we expect the hook got different value now
    wrapper.update();

    selected = wrapper.find('Typeahead').prop('selected');
    expect(selected[1].value).toBe('dnk');
    expect(selected[2].value).toBe('no');
  });
});
