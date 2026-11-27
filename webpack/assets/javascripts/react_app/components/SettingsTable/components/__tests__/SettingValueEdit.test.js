import React from 'react';
import { act, fireEvent, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { rtlHelpers } from '../../../../common/rtlTestHelpers';
import SettingValueEdit from '../SettingValueEdit';

const { renderWithStore } = rtlHelpers;

const setting = {
  id: 5,
  name: 'entries_per_page',
  fullName: 'Entries per page',
  value: '20',
  settingsType: 'string',
  encrypted: false,
};

const renderEdit = (props = {}) =>
  renderWithStore(
    <SettingValueEdit setting={setting} updateSetting={jest.fn()} {...props} />
  );

const errorItems = container =>
  container.querySelectorAll('.pf-v6-c-helper-text__item.pf-m-error');

describe('SettingValueEdit', () => {
  it('shows no error indicator while the value is valid', () => {
    const { container } = renderEdit();
    // PF6 HelperTextItem draws a status icon for variant="error" even when empty
    expect(errorItems(container)).toHaveLength(0);
    expect(
      container.querySelector('#setting-input-entries_per_page')
    ).not.toHaveAttribute('aria-invalid', 'true');
  });

  it('shows the error text with the error style for an invalid value', async () => {
    const { container } = renderEdit();
    const input = container.querySelector('#setting-input-entries_per_page');
    await act(async () => {
      fireEvent.change(input, { target: { value: '   ' } });
    });
    await act(async () => {
      fireEvent.keyDown(input, { key: 'Enter' });
    });
    const items = errorItems(container);
    expect(items).toHaveLength(1);
    expect(items[0]).toHaveTextContent('Invalid value');
  });

  it('shows the encrypted hint without the error style', () => {
    const { container } = renderEdit({
      setting: { ...setting, encrypted: true },
    });
    expect(screen.getByText(/This setting is encrypted/)).toBeInTheDocument();
    expect(errorItems(container)).toHaveLength(0);
  });
});
