import React from 'react';
import { act, fireEvent, render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { flushPatternflyTimers } from '../../../../../common/rtlTestHelpers';
import SelectAllCheckbox from './index';

const baseProps = {
  selectNone: jest.fn(),
  selectPage: jest.fn(),
  selectAll: jest.fn(),
  selectedCount: 0,
  pageRowCount: 5,
  totalCount: 12,
  areAllRowsOnPageSelected: false,
  areAllRowsSelected: false,
};

const openMenu = async () => {
  await act(async () => {
    fireEvent.click(screen.getByRole('button', { name: 'Select all options' }));
  });
  await flushPatternflyTimers();
};

describe('SelectAllCheckbox', () => {
  beforeEach(() => jest.clearAllMocks());

  it('selects all rows when the empty checkbox is clicked', () => {
    render(<SelectAllCheckbox {...baseProps} />);
    const checkbox = screen.getByRole('checkbox', { name: 'Select all' });
    expect(checkbox).not.toBeChecked();
    fireEvent.click(checkbox);
    expect(baseProps.selectAll).toHaveBeenCalledWith(true);
  });

  it('selects the page when select all is not supported', () => {
    const { selectAll, ...props } = baseProps;
    render(<SelectAllCheckbox {...props} />);
    fireEvent.click(screen.getByRole('checkbox', { name: 'Select all' }));
    expect(baseProps.selectPage).toHaveBeenCalledTimes(1);
  });

  it('shows the selected count and clears a partial selection', () => {
    render(<SelectAllCheckbox {...baseProps} selectedCount={3} />);
    expect(screen.getByText('3 selected')).toBeInTheDocument();
    const checkbox = screen.getByRole('checkbox', { name: 'Select all' });
    expect(checkbox.indeterminate).toBe(true);
    fireEvent.click(checkbox);
    expect(baseProps.selectNone).toHaveBeenCalledTimes(1);
  });

  it('offers none, page and all options with counts', async () => {
    render(<SelectAllCheckbox {...baseProps} />);
    await openMenu();
    expect(
      screen.getByRole('menuitem', { name: 'Select none (0)' })
    ).toBeDisabled();
    expect(
      screen.getByRole('menuitem', { name: 'Select page (5)' })
    ).toBeEnabled();
    expect(
      screen.getByRole('menuitem', { name: 'Select all (12)' })
    ).toBeEnabled();
  });

  it('selects the page from the menu and closes it', async () => {
    render(<SelectAllCheckbox {...baseProps} />);
    await openMenu();
    await act(async () => {
      fireEvent.click(
        screen.getByRole('menuitem', { name: 'Select page (5)' })
      );
    });
    await flushPatternflyTimers();
    expect(baseProps.selectPage).toHaveBeenCalledTimes(1);
    expect(
      screen.getByRole('button', { name: 'Select all options' })
    ).toHaveAttribute('aria-expanded', 'false');
  });

  it('shows select default instead of select none when provided', async () => {
    const selectDefault = jest.fn();
    render(
      <SelectAllCheckbox
        {...baseProps}
        selectDefault={selectDefault}
        selectedDefaultCount={2}
      />
    );
    await openMenu();
    await act(async () => {
      fireEvent.click(
        screen.getByRole('menuitem', { name: 'Select default (2)' })
      );
    });
    await flushPatternflyTimers();
    expect(selectDefault).toHaveBeenCalledTimes(1);
    expect(
      screen.queryByRole('menuitem', { name: /Select none/ })
    ).not.toBeInTheDocument();
  });
});
