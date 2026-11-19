import React from 'react';
import { act, fireEvent, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import {
  flushPatternflyTimers,
  rtlHelpers,
} from '../../../../common/rtlTestHelpers';
import { ActionFormatter } from './helpers';

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
