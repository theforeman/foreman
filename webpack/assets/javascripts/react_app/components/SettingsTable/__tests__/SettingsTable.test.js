import React from 'react';
import { act, screen, within, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';

import { rtlHelpers } from '../../../common/rtlTestHelpers';
import API from '../../../redux/API/API';
import { groupedSettings } from '../../SettingRecords/__tests__/SettingRecords.fixtures';
import SettingsTable from '../SettingsTable';

const { renderWithStore } = rtlHelpers;
const generalSettings = groupedSettings.General;

const settingByName = name =>
  generalSettings.find(setting => setting.name === name);

const renderTable = (settings = generalSettings) =>
  renderWithStore(<SettingsTable settings={settings} />);

const getSettingRow = name =>
  screen.getByRole('row', {
    name: accessibleName => accessibleName.includes(name),
  });

const openEdit = async name => {
  const row = getSettingRow(name);

  await userEvent.click(within(row).getByRole('button'));

  return row;
};

const submitEdit = async row => {
  const buttons = within(row).getAllByRole('button');

  await act(async () => {
    await userEvent.click(buttons[buttons.length - 1]);
  });
};

const cancelEdit = async row => {
  await userEvent.click(within(row).getAllByRole('button')[0]);
};

const submitArrayValue = async (text = '') => {
  const row = await openEdit('HTTP(S) proxy except hosts');
  const textarea = within(row).getByRole('textbox');

  if (text !== '') {
    await userEvent.type(textarea, `{selectall}${text}`);
    await waitFor(() => {
      expect(textarea).toHaveValue(text);
    });
  } else {
    await userEvent.clear(textarea);
    await waitFor(() => {
      expect(textarea).toHaveValue('');
    });
  }

  await submitEdit(row);
};

const expectDisplayedValue = async (settingName, value) => {
  await waitFor(() => {
    const row = getSettingRow(settingName);

    expect(within(row).queryByRole('textbox')).not.toBeInTheDocument();
    expect(within(row).queryByRole('combobox')).not.toBeInTheDocument();
    expect(within(row).getByText(value)).toBeInTheDocument();
  });
};

const expectSettingRow = ({ name, value, description }) => {
  const row = getSettingRow(name);

  expect(within(row).getByText(name)).toBeInTheDocument();
  expect(within(row).getByText(value)).toBeInTheDocument();
  expect(within(row).getByText(description)).toBeInTheDocument();
};

describe('SettingsTable', () => {
  beforeEach(() => {
    API.put.mockImplementation((_url, params) =>
      Promise.resolve({ data: { value: params.value } })
    );
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('renders Name, Value and Description column headers', () => {
    renderTable();

    expect(
      screen.getByRole('columnheader', { name: 'Name' })
    ).toBeInTheDocument();
    expect(
      screen.getByRole('columnheader', { name: 'Value' })
    ).toBeInTheDocument();
    expect(
      screen.getByRole('columnheader', { name: 'Description' })
    ).toBeInTheDocument();
  });

  it('renders each general setting name, value and description', () => {
    renderTable();

    expectSettingRow({
      name: 'Administrator email address',
      value: 'root@example.com',
      description: 'The default administrator email address',
    });
    expectSettingRow({
      name: 'Append domain names to the host',
      value: 'Yes',
      description:
        'Foreman will append domain names when new hosts are provisioned',
    });
    expectSettingRow({
      name: 'Default timezone',
      value: '(GMT +07:00) Bangkok',
      description: 'Timezone to use for new users',
    });
    expectSettingRow({
      name: 'HTTP(S) proxy except hosts',
      value: '[localhost, 127.0.0.1]',
      description:
        'Set hostnames to which requests are not to be proxied. Requests to the local host are excluded by default.',
    });

    expect(screen.getAllByRole('row')).toHaveLength(5);
  });

  it('submits a new string value', async () => {
    renderTable();

    expect(screen.getByText('root@example.com')).toBeInTheDocument();
    expect(screen.queryByText('Test')).not.toBeInTheDocument();

    const row = await openEdit('Administrator email address');
    const input = within(row).getByRole('textbox');

    await userEvent.clear(input);
    await userEvent.type(input, 'Test');
    await waitFor(() => {
      expect(input).toHaveValue('Test');
    });
    await submitEdit(row);

    expect(API.put).toHaveBeenCalledWith(
      `/api/settings/${settingByName('administrator').id}`,
      expect.objectContaining({ value: 'Test' }),
      expect.any(Object)
    );
    await expectDisplayedValue('Administrator email address', 'Test');
    expect(screen.queryByText('root@example.com')).not.toBeInTheDocument();
  });

  it('submits a boolean selection', async () => {
    renderTable();

    expect(screen.getByText('Yes')).toBeInTheDocument();
    expect(screen.queryByText('No')).not.toBeInTheDocument();

    const row = await openEdit('Append domain names to the host');
    const select = within(row).getByRole('combobox', {
      name: 'Boolean select',
    });

    await userEvent.selectOptions(
      select,
      within(select).getByRole('option', { name: 'No' })
    );
    await submitEdit(row);

    expect(API.put).toHaveBeenCalledWith(
      `/api/settings/${settingByName('display_fqdn_for_hosts').id}`,
      expect.objectContaining({ value: 'false' }),
      expect.any(Object)
    );
    await expectDisplayedValue('Append domain names to the host', 'No');
    expect(screen.queryByText('Yes')).not.toBeInTheDocument();
  });

  it('submits a selected timezone value', async () => {
    renderTable();

    expect(screen.getByText('(GMT +07:00) Bangkok')).toBeInTheDocument();
    expect(screen.queryByText('(GMT -09:00) Alaska')).not.toBeInTheDocument();

    const row = await openEdit('Default timezone');
    const select = within(row).getByRole('combobox', {
      name: 'Multiple select',
    });

    await userEvent.selectOptions(
      select,
      within(select).getByRole('option', { name: '(GMT -09:00) Alaska' })
    );
    await submitEdit(row);

    expect(API.put).toHaveBeenCalledWith(
      `/api/settings/${settingByName('default_timezone').id}`,
      expect.objectContaining({ value: 'Alaska' }),
      expect.any(Object)
    );
    await expectDisplayedValue('Default timezone', '(GMT -09:00) Alaska');
  });

  it('cancels editing without submitting', async () => {
    renderTable();

    const row = await openEdit('Administrator email address');
    const input = within(row).getByRole('textbox');

    await userEvent.clear(input);
    await userEvent.type(input, 'Test');
    await cancelEdit(row);

    expect(within(row).queryByRole('textbox')).not.toBeInTheDocument();
    expect(screen.getByText('root@example.com')).toBeInTheDocument();
    expect(screen.queryByText('Test')).not.toBeInTheDocument();
    expect(API.put).not.toHaveBeenCalled();
  });

  it('submits a single array value', async () => {
    renderTable();

    expect(screen.getByText('[localhost, 127.0.0.1]')).toBeInTheDocument();
    expect(screen.queryByText('[Test]')).not.toBeInTheDocument();

    await submitArrayValue('Test');

    expect(API.put).toHaveBeenCalledWith(
      `/api/settings/${settingByName('http_proxy_except_list').id}`,
      expect.objectContaining({ value: ['Test'] }),
      expect.any(Object)
    );
    await expectDisplayedValue('HTTP(S) proxy except hosts', '[Test]');
  });

  it('submits multiple array values', async () => {
    renderTable();

    expect(screen.queryByText('[Test, Test2]')).not.toBeInTheDocument();

    await submitArrayValue('Test, Test2');

    expect(API.put).toHaveBeenCalledWith(
      `/api/settings/${settingByName('http_proxy_except_list').id}`,
      expect.objectContaining({ value: ['Test', 'Test2'] }),
      expect.any(Object)
    );
    await expectDisplayedValue('HTTP(S) proxy except hosts', '[Test, Test2]');
  });

  it('submits an empty array value', async () => {
    renderTable();

    expect(screen.getByText('[localhost, 127.0.0.1]')).toBeInTheDocument();
    expect(screen.queryByText('[]')).not.toBeInTheDocument();

    await submitArrayValue();

    expect(API.put).toHaveBeenCalledWith(
      `/api/settings/${settingByName('http_proxy_except_list').id}`,
      expect.objectContaining({ value: [] }),
      expect.any(Object)
    );
    await expectDisplayedValue('HTTP(S) proxy except hosts', '[]');
  });
});
