import React from 'react';
import { screen, fireEvent, render, act } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';

import { ActionButtons } from './ActionButtons';
import { buttons } from './ActionButtons.fixtures';

const fixtures = {
  none: { buttons: [] },
  one: { buttons: [buttons[0]] },
  many: { buttons },
};

describe('ActionButtons', () => {
  it('renders with 0 buttons', () => {
    render(<ActionButtons {...fixtures.none} />);
    expect(screen.queryByRole('button')).not.toBeInTheDocument();
  });

  it('renders 1 button', () => {
    render(<ActionButtons {...fixtures.one} />);
    expect(screen.getByRole('button')).toHaveTextContent('first');
  });

  it('renders 2 buttons initially and shows more after clicking toggle', async () => {
    render(<ActionButtons {...fixtures.many} />);
    const buttons = screen.getAllByRole('button');
    expect(buttons).toHaveLength(2);
    expect(screen.getByRole('button', { name: 'first' })).toBeInTheDocument();
    const toggleButton = screen.getByRole('button', {
      name: 'Menu toggle with action split button'
    });
    expect(toggleButton).toBeInTheDocument();

    expect(screen.queryByText('second')).not.toBeInTheDocument();
    expect(screen.queryByText('third')).not.toBeInTheDocument();
    await act(async () => fireEvent.click(toggleButton));
    expect(screen.getByText('second')).toBeInTheDocument();
    expect(screen.getByText('third')).toBeInTheDocument();
    const dropdownItems = screen.getAllByRole('menuitem');
    expect(dropdownItems).toHaveLength(3);
    expect(dropdownItems[2]).toBeDisabled();
  });
});
