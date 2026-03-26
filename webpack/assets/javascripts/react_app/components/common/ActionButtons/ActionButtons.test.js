import React from 'react';
import { act, fireEvent, render, screen, within } from '@testing-library/react';
import '@testing-library/jest-dom';

import { ActionButtons } from './ActionButtons';

describe('ActionButtons', () => {
  const fixtures = {
    none: { buttons: [] },
    one: { buttons: [{ title: 'first', action: { onClick: jest.fn() } }] },
    many: {
      buttons: [
        { title: 'first', action: { onClick: jest.fn() } },
        { title: 'second', action: { onClick: jest.fn() } },
        { title: 'third', action: { onClick: jest.fn(), disabled: true } },
      ],
    },
  };

  test('renders with 0 buttons', () => {
    const { container } = render(<ActionButtons {...fixtures.none} />);
    expect(container).toBeEmptyDOMElement();
    expect(screen.queryByRole('button')).not.toBeInTheDocument();
  });

  test('renders 1 button', () => {
    render(<ActionButtons {...fixtures.one} />);
    expect(screen.getByRole('button')).toHaveTextContent('first');
  });

  test('single button calls action on click', () => {
    const onClick = jest.fn();
    render(<ActionButtons buttons={[{ title: 'first', action: { onClick } }]} />);
    fireEvent.click(screen.getByRole('button', { name: 'first' }));
    expect(onClick).toHaveBeenCalledTimes(1);
  });

  test('renders 2 buttons initially and shows more after clicking toggle', async () => {
    render(<ActionButtons {...fixtures.many} />);
    const buttons = screen.getAllByRole('button');
    expect(buttons).toHaveLength(2);
    expect(screen.getByRole('button', { name: 'first' })).toBeInTheDocument();
    const menuToggle = screen.getByRole('button', {
      name: /menu toggle with action split button/i,
    });
    expect(menuToggle).toBeInTheDocument();
    expect(screen.queryByText('second')).not.toBeInTheDocument();
    expect(screen.queryByText('third')).not.toBeInTheDocument();
    await act(async () => fireEvent.click(menuToggle));
    expect(screen.getByText('second')).toBeInTheDocument();
    expect(screen.getByText('third')).toBeInTheDocument();
    const dropdownItems = screen.getAllByRole('menuitem');
    expect(dropdownItems).toHaveLength(2);
    expect(dropdownItems[1]).toBeDisabled();
  });

  test('opens dropdown and calls secondary action', async () => {
    const secondAction = jest.fn();
    render(
      <ActionButtons
        buttons={[
          { title: 'first', action: { onClick: jest.fn() } },
          { title: 'second', action: { onClick: secondAction } },
          { title: 'third', action: { onClick: jest.fn(), disabled: true } },
        ]}
      />
    );
    await act(async () => {
      fireEvent.click(
        screen.getByRole('button', {
          name: /menu toggle with action split button/i,
        })
      );
      await new Promise(resolve => setTimeout(resolve, 0));
    });
    fireEvent.click(screen.getByRole('menuitem', { name: 'second' }));
    expect(secondAction).toHaveBeenCalledTimes(1);
  });

  test('disables split menu items', async () => {
    render(
      <ActionButtons
        buttons={[
          { title: 'first', action: { onClick: jest.fn() } },
          { title: 'second', action: { onClick: jest.fn(), disabled: true } },
          { title: 'third', action: { onClick: jest.fn(), disabled: true } },
        ]}
      />
    );

    expect(screen.getByRole('button', { name: 'first' })).not.toBeDisabled();
    await act(async () => {
      fireEvent.click(
        screen.getByRole('button', {
          name: /menu toggle with action split button/i,
        })
      );
      await new Promise(resolve => setTimeout(resolve, 0));
    });
    const menu = screen.getByRole('menu');
    expect(within(menu).getByRole('menuitem', { name: 'second' })).toBeDisabled();
    expect(within(menu).getByRole('menuitem', { name: 'third' })).toBeDisabled();
  });
});
