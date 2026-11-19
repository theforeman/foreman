import React from 'react';
import { act, fireEvent, screen, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import { API } from '../../../../redux/API';
import {
  flushPatternflyTimers,
  rtlHelpers,
} from '../../../../common/rtlTestHelpers';
import PowerStatusDropDown from './PowerStatusDropDown';

jest.mock('../../../../redux/API/API');

const { renderWithStore } = rtlHelpers;
const POWER_TOGGLE = 'Power status toggle';

const renderDropdown = props =>
  renderWithStore(
    <PowerStatusDropDown hostID="1" hasPowerPermission {...props} />
  );

const openMenu = async () => {
  await waitFor(() =>
    expect(screen.getByRole('button', { name: POWER_TOGGLE })).toBeEnabled()
  );
  await act(async () => {
    fireEvent.click(screen.getByRole('button', { name: POWER_TOGGLE }));
  });
  await flushPatternflyTimers();
};

describe('PowerStatusDropDown', () => {
  beforeEach(() => {
    API.get.mockResolvedValue({
      data: { state: 'on', title: 'On', statusText: 'Powered on' },
    });
  });

  it('offers on/off for non-BMC hosts and disables the current state', async () => {
    renderDropdown();
    await openMenu();
    expect(screen.getByRole('menuitem', { name: 'On' })).toBeDisabled();
    expect(screen.getByRole('menuitem', { name: 'Off' })).toBeEnabled();
    expect(
      screen.queryByRole('menuitem', { name: 'Reboot' })
    ).not.toBeInTheDocument();
  });

  it('offers BMC power actions for BMC hosts', async () => {
    renderDropdown({ isBmc: true });
    await openMenu();
    expect(screen.getByRole('menuitem', { name: 'Reboot' })).toBeEnabled();
    expect(screen.getByRole('menuitem', { name: 'Cycle' })).toBeEnabled();
  });

  it('asks for confirmation before changing power and closes the menu', async () => {
    const { store } = renderDropdown();
    await openMenu();
    await act(async () => {
      fireEvent.click(screen.getByRole('menuitem', { name: 'Off' }));
    });
    await flushPatternflyTimers();
    expect(store.getState().confirmModal.isOpen).toBe(true);
    expect(screen.getByRole('button', { name: POWER_TOGGLE })).toHaveAttribute(
      'aria-expanded',
      'false'
    );
  });

  it('disables the toggle without power permission', async () => {
    renderDropdown({ hasPowerPermission: false });
    await waitFor(() => expect(API.get).toHaveBeenCalled());
    expect(screen.getByRole('button', { name: POWER_TOGGLE })).toBeDisabled();
  });
});
