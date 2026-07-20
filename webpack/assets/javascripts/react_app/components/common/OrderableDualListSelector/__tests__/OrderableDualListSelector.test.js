import React, { useState } from 'react';
import { act, render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';

import OrderableDualListSelector from '../OrderableDualListSelector';

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

const StatefulDualList = ({
  initialAvailable,
  initialChosen,
  onListChange = jest.fn(),
  ...props
}) => {
  const [availableOptions, setAvailableOptions] = useState(initialAvailable);
  const [chosenOptions, setChosenOptions] = useState(initialChosen);

  const handleListChange = (nextAvailable, nextChosen) => {
    setAvailableOptions(nextAvailable);
    setChosenOptions(nextChosen);
    onListChange(nextAvailable, nextChosen);
  };

  return (
    <OrderableDualListSelector
      {...props}
      availableOptions={availableOptions}
      chosenOptions={chosenOptions}
      onListChange={handleListChange}
    />
  );
};

const defaultProps = {
  id: 'ansible-roles',
  availableOptions: ['role.a', 'role.b'],
  chosenOptions: ['role.c'],
  onListChange: jest.fn(),
  availableOptionsTitle: 'Available Ansible roles',
  chosenOptionsTitle: 'Assigned Ansible roles',
};

describe('OrderableDualListSelector', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    dragDropOnDropRef.current = null;
  });

  it('renders available and chosen options from string lists', () => {
    render(<OrderableDualListSelector {...defaultProps} />);

    expect(screen.getByText('Available Ansible roles')).toBeInTheDocument();
    expect(screen.getByText('Assigned Ansible roles')).toBeInTheDocument();
    expect(screen.getByText('role.a')).toBeInTheDocument();
    expect(screen.getByText('role.b')).toBeInTheDocument();
    expect(screen.getByText('role.c')).toBeInTheDocument();
  });

  it('moves selected available options to chosen', async () => {
    render(<OrderableDualListSelector {...defaultProps} />);

    await userEvent.click(screen.getByRole('option', { name: 'role.b' }));
    await userEvent.click(screen.getByRole('button', { name: 'Add selected' }));

    expect(defaultProps.onListChange).toHaveBeenCalledWith(
      ['role.a'],
      ['role.c', 'role.b']
    );
  });

  it('moves selected chosen options to available', async () => {
    render(<OrderableDualListSelector {...defaultProps} />);

    await userEvent.click(screen.getByRole('option', { name: 'role.c' }));
    await userEvent.click(
      screen.getByRole('button', { name: 'Remove selected' })
    );

    expect(defaultProps.onListChange).toHaveBeenCalledWith(
      ['role.a', 'role.b', 'role.c'],
      []
    );
  });

  it('does not duplicate options when re-adding a removed value', async () => {
    const onListChange = jest.fn();

    render(
      <StatefulDualList
        id="ansible-roles"
        initialAvailable={[]}
        initialChosen={['role.c']}
        onListChange={onListChange}
        availableOptionsTitle="Available Ansible roles"
        chosenOptionsTitle="Assigned Ansible roles"
      />
    );

    await userEvent.click(screen.getByRole('option', { name: 'role.c' }));
    await userEvent.click(
      screen.getByRole('button', { name: 'Remove selected' })
    );
    await userEvent.click(screen.getByRole('option', { name: 'role.c' }));
    await userEvent.click(screen.getByRole('button', { name: 'Add selected' }));

    expect(onListChange).toHaveBeenLastCalledWith([], ['role.c']);
  });

  it('reorders chosen options on drop', () => {
    const onListChange = jest.fn();

    render(
      <OrderableDualListSelector
        {...defaultProps}
        availableOptions={['role.a']}
        chosenOptions={['role.b', 'role.c', 'role.d']}
        onListChange={onListChange}
      />
    );

    expect(dragDropOnDropRef.current).toEqual(expect.any(Function));

    let dropResult;
    act(() => {
      dropResult = dragDropOnDropRef.current({ index: 0 }, { index: 2 });
    });

    expect(dropResult).toBe(true);
    expect(onListChange).toHaveBeenCalledWith(
      ['role.a'],
      ['role.c', 'role.d', 'role.b']
    );
  });

  it('does not reorder when drop has no destination', () => {
    const onListChange = jest.fn();

    render(
      <OrderableDualListSelector
        {...defaultProps}
        availableOptions={['role.a']}
        chosenOptions={['role.b', 'role.c']}
        onListChange={onListChange}
      />
    );

    let dropResult;
    act(() => {
      dropResult = dragDropOnDropRef.current({ index: 0 }, null);
    });

    expect(dropResult).toBe(false);
    expect(onListChange).not.toHaveBeenCalled();
  });
});
