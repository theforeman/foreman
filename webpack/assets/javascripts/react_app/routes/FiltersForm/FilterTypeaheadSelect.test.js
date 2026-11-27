import React from 'react';
import { act, fireEvent, render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { flushPatternflyTimers } from '../../common/rtlTestHelpers';
import { FilterTypeaheadSelect } from './FilterTypeaheadSelect';

const options = [
  { value: 1, label: 'Viewer' },
  { value: 2, label: 'Manager' },
  { value: 3, label: 'Site manager' },
];
const INPUT_LABEL = 'Select a role';
const TOGGLE_LABEL = 'role toggle';

const renderSelect = props =>
  render(
    <FilterTypeaheadSelect
      ouiaId="test-select"
      inputAriaLabel={INPUT_LABEL}
      toggleAriaLabel={TOGGLE_LABEL}
      options={options}
      selectedLabel=""
      onSelect={jest.fn()}
      {...props}
    />
  );

const openMenu = async () => {
  await act(async () => {
    fireEvent.click(screen.getByRole('button', { name: TOGGLE_LABEL }));
  });
  await flushPatternflyTimers();
};

describe('FilterTypeaheadSelect', () => {
  it('shows the selected label in the labelled input', () => {
    renderSelect({ selectedLabel: 'Manager' });
    expect(screen.getByLabelText(INPUT_LABEL)).toHaveValue('Manager');
  });

  it('updates the input when the selected label arrives later', () => {
    const { rerender } = renderSelect();
    expect(screen.getByLabelText(INPUT_LABEL)).toHaveValue('');
    rerender(
      <FilterTypeaheadSelect
        ouiaId="test-select"
        inputAriaLabel={INPUT_LABEL}
        toggleAriaLabel={TOGGLE_LABEL}
        options={options}
        selectedLabel="Viewer"
        onSelect={jest.fn()}
      />
    );
    expect(screen.getByLabelText(INPUT_LABEL)).toHaveValue('Viewer');
  });

  it('lists all options when opened from the toggle', async () => {
    renderSelect();
    await openMenu();
    expect(screen.getAllByRole('option')).toHaveLength(options.length);
  });

  it('filters options by typed text, case-insensitively', async () => {
    renderSelect();
    await act(async () => {
      fireEvent.change(screen.getByLabelText(INPUT_LABEL), {
        target: { value: 'MANAG' },
      });
    });
    await flushPatternflyTimers();
    expect(
      screen.getAllByRole('option').map(option => option.textContent)
    ).toEqual(['Manager', 'Site manager']);
  });

  it('shows a disabled no-results option when nothing matches', async () => {
    renderSelect();
    await act(async () => {
      fireEvent.change(screen.getByLabelText(INPUT_LABEL), {
        target: { value: 'zzz' },
      });
    });
    await flushPatternflyTimers();
    const noResults = screen.getByRole('option', {
      name: 'No results found for "zzz"',
    });
    expect(noResults).toHaveAttribute('aria-disabled', 'true');
  });

  it('calls onSelect with the value, shows the label and closes', async () => {
    const onSelect = jest.fn();
    renderSelect({ onSelect });
    await openMenu();
    await act(async () => {
      fireEvent.click(screen.getByRole('option', { name: 'Site manager' }));
    });
    await flushPatternflyTimers();
    expect(onSelect).toHaveBeenCalledWith(3);
    expect(screen.getByLabelText(INPUT_LABEL)).toHaveValue('Site manager');
    expect(screen.getByRole('button', { name: TOGGLE_LABEL })).toHaveAttribute(
      'aria-expanded',
      'false'
    );
  });

  it('selects with arrow keys and Enter', async () => {
    const onSelect = jest.fn();
    renderSelect({ onSelect });
    const input = screen.getByLabelText(INPUT_LABEL);
    await act(async () => {
      fireEvent.keyDown(input, { key: 'ArrowDown' });
    });
    await flushPatternflyTimers();
    await act(async () => {
      fireEvent.keyDown(input, { key: 'ArrowDown' });
    });
    await flushPatternflyTimers();
    await act(async () => {
      fireEvent.keyDown(input, { key: 'Enter' });
    });
    await flushPatternflyTimers();
    expect(onSelect).toHaveBeenCalledWith(2);
    expect(input).toHaveValue('Manager');
  });

  it('restores the selected label when closed without choosing', async () => {
    renderSelect({ selectedLabel: 'Manager' });
    const input = screen.getByLabelText(INPUT_LABEL);
    await act(async () => {
      fireEvent.change(input, { target: { value: 'Vie' } });
    });
    await flushPatternflyTimers();
    expect(input).toHaveValue('Vie');
    await act(async () => {
      fireEvent.keyDown(input, { key: 'Escape' });
    });
    await flushPatternflyTimers();
    expect(input).toHaveValue('Manager');
  });
});
