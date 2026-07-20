import React from 'react';
import { act, render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';

import OrderableDualList from '../OrderableDualList';

// Capture PF DragDrop onDrop so reorder can be exercised without pointer simulation.
const dragDropOnDropRef = { current: null };

jest.mock('@patternfly/react-core', () => {
  const ReactActual = require('react');
  const actual = jest.requireActual('@patternfly/react-core');

  return {
    ...actual,
    DragDrop: props => {
      dragDropOnDropRef.current = props.onDrop;
      return ReactActual.createElement(actual.DragDrop, props);
    },
  };
});

const bootDeviceOptions = [
  { label: 'Harddisk', value: 'disk' },
  { label: 'Network', value: 'network' },
  { label: 'CD-ROM', value: 'cdrom' },
  { label: 'Floppy', value: 'floppy' },
];

const hiddenInputs = container =>
  [...container.querySelectorAll('input[type="hidden"]')];

describe('OrderableDualList', () => {
  beforeEach(() => {
    dragDropOnDropRef.current = null;
  });

  it('renders hidden inputs in boot order when name is provided', () => {
    const { container } = render(
      <OrderableDualList
        id="boot-order"
        name="host[compute_attributes][boot_order][]"
        options={bootDeviceOptions}
        defaultValue={['network', 'disk']}
      />
    );

    const inputs = hiddenInputs(container);
    expect(inputs).toHaveLength(2);
    expect(inputs[0]).toHaveAttribute('value', 'network');
    expect(inputs[1]).toHaveAttribute('value', 'disk');
    expect(inputs[0]).toHaveAttribute(
      'name',
      'host[compute_attributes][boot_order][]'
    );
  });

  it('moves selected available options into the chosen list', async () => {
    const onChange = jest.fn();
    const { container } = render(
      <OrderableDualList
        id="boot-order"
        name="host[compute_attributes][boot_order][]"
        options={bootDeviceOptions}
        defaultValue={[]}
        onChange={onChange}
      />
    );

    await userEvent.click(screen.getByRole('option', { name: 'Network' }));
    await userEvent.click(screen.getByRole('button', { name: 'Add selected' }));

    expect(onChange).toHaveBeenLastCalledWith(['network']);

    const inputs = hiddenInputs(container);
    expect(inputs).toHaveLength(1);
    expect(inputs[0]).toHaveAttribute('value', 'network');
  });

  it('reorders chosen options on drop and updates hidden inputs', () => {
    const onChange = jest.fn();
    const { container } = render(
      <OrderableDualList
        id="boot-order"
        name="host[compute_attributes][boot_order][]"
        options={bootDeviceOptions}
        defaultValue={['network', 'disk', 'cdrom']}
        onChange={onChange}
      />
    );

    expect(dragDropOnDropRef.current).toEqual(expect.any(Function));

    let dropResult;
    act(() => {
      dropResult = dragDropOnDropRef.current({ index: 0 }, { index: 2 });
    });

    expect(dropResult).toBe(true);
    expect(onChange).toHaveBeenLastCalledWith(['disk', 'cdrom', 'network']);

    const inputs = hiddenInputs(container);
    expect(inputs.map(input => input.getAttribute('value'))).toEqual([
      'disk',
      'cdrom',
      'network',
    ]);
  });

  it('does not reorder when drop has no destination', () => {
    const onChange = jest.fn();
    const { container } = render(
      <OrderableDualList
        id="boot-order"
        name="host[compute_attributes][boot_order][]"
        options={bootDeviceOptions}
        defaultValue={['network', 'disk']}
        onChange={onChange}
      />
    );

    let dropResult;
    act(() => {
      dropResult = dragDropOnDropRef.current({ index: 0 }, null);
    });

    expect(dropResult).toBe(false);
    expect(onChange).not.toHaveBeenCalled();
    expect(hiddenInputs(container).map(input => input.getAttribute('value'))).toEqual(
      ['network', 'disk']
    );
  });
});
