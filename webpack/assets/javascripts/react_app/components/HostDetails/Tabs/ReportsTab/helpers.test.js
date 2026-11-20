import React from 'react';
import { act, fireEvent, render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import {
  flushPatternflyTimers,
  rtlHelpers,
} from '../../../../common/rtlTestHelpers';
import { ActionFormatter, statusFormatter } from './helpers';

const { renderWithStore } = rtlHelpers;

// ActionFormatter uses hooks, so it has to run during a component render
const ActionCell = ({ report }) => ActionFormatter(report, jest.fn());

const openActions = async () => {
  await act(async () => {
    fireEvent.click(screen.getByRole('button', { name: 'Actions' }));
  });
  await flushPatternflyTimers();
};

describe('ReportsTab ActionFormatter', () => {
  it('asks for confirmation before deleting a report and closes the menu', async () => {
    const { store } = renderWithStore(
      <ActionCell report={{ id: 3, can_delete: true }} />
    );
    await openActions();
    await act(async () => {
      fireEvent.click(screen.getByRole('menuitem', { name: 'Delete' }));
    });
    await flushPatternflyTimers();
    expect(store.getState().confirmModal.isOpen).toBe(true);
    expect(store.getState().confirmModal.title).toBe('Delete report?');
    expect(screen.getByRole('button', { name: 'Actions' })).toHaveAttribute(
      'aria-expanded',
      'false'
    );
  });

  it('disables delete without permission', async () => {
    renderWithStore(<ActionCell report={{ id: 3, can_delete: false }} />);
    await openActions();
    expect(screen.getByRole('menuitem', { name: 'Delete' })).toBeDisabled();
  });
});

describe('ReportsTab statusFormatter', () => {
  const contentOf = container =>
    container.querySelector('.pf-v6-c-icon .pf-v6-c-icon__content');

  it.each([
    ['failed', 'pf-m-danger'],
    ['failed_restarts', 'pf-m-danger'],
    ['applied', 'pf-m-success'],
  ])('colors %s icons with %s', (statusName, modifier) => {
    const { container } = render(
      <div>{statusFormatter(statusName, { [statusName]: 2 })}</div>
    );
    expect(contentOf(container)).toHaveClass(modifier);
  });

  it('colors restarted icons orange', () => {
    const { container } = render(
      <div>{statusFormatter('restarted', { restarted: 2 })}</div>
    );
    expect(
      container
        .querySelector('.pf-v6-c-icon')
        .style.getPropertyValue('--pf-v6-c-icon__content--Color')
    ).toBe('var(--pf-t--global--color--nonstatus--orange--default)');
  });
});
