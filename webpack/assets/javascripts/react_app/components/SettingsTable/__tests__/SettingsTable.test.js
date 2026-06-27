import React from "react";
import {render, screen, within} from '@testing-library/react'
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom'
import {Provider} from "react-redux";

import { createStore, applyMiddleware } from 'redux';
import thunk from 'redux-thunk';

import { groupedSettings } from '../../SettingRecords/__tests__/SettingRecords.fixtures';
import SettingsTable from '../SettingsTable';
import {APIActions} from "../../../redux/API";

// Real store (not redux-mock-store, per testing guidelines). The table reads
// nothing from state, so the initial state is empty; thunk mirrors the app's
// dispatch pipeline for the (mocked) APIActions.put calls.
const store = createStore((state = {}) => state, applyMiddleware(thunk));

jest.spyOn(APIActions, 'put').mockReturnValue({ type: 'DUMMY' });

async function extracted(text = '') {
  // http_proxy_except_list is the fourth body row
  const proxyRow = screen.getAllByRole('row')[4];
  const editButton = within(proxyRow).getByRole('button');

  expect(editButton).toBeInTheDocument();
  await userEvent.click(editButton);

  const input = within(proxyRow).getByRole('textbox');
  expect(input).toBeInTheDocument();

  await userEvent.clear(input);
  if (text !== '')  await userEvent.type(input, text);

  // edit mode renders two icon-only buttons in the row: [cancel, submit]
  const submitBtn = within(proxyRow).getAllByRole('button')[1];
  expect(submitBtn).toBeInTheDocument();
  await userEvent.click(submitBtn);
}

describe('SettingsTable', () => {
  afterEach(() => {
    jest.clearAllMocks();
  });

  beforeEach(() => {
    render(
        <Provider store={store}>
          <SettingsTable settings={groupedSettings['General']} />
        </Provider>
    );
  });

  it('renders the header row with the correct OUIA id', () => {
    const headerRow = document.querySelector(
        'tr[data-ouia-component-id="setting-table-heading-row"]'
    );
    expect(headerRow).toBeInTheDocument();
  });

  it('renders Name, Value and Description column headers', () => {
    const headers = screen.getAllByRole('columnheader')

    expect(headers).toHaveLength(3);

    expect(headers[0]).toHaveTextContent('Name');
    expect(headers[1]).toHaveTextContent('Value');
    expect(headers[2]).toHaveTextContent('Description');
  });

  test('renders one row per setting + header', () => {
    const rows = screen.getAllByRole('row')

    expect(rows).toHaveLength(5)
  })

  it('string input test', async () => {
    const allRows = screen.getAllByRole('row');
    expect(allRows.length).toBeGreaterThan(1); // sanity check

    const firstBodyRow = allRows[1];

    const {getByRole} = within(firstBodyRow);
    const editButton = getByRole('button');

    expect(editButton).toBeInTheDocument();
    await userEvent.click(editButton);

    const input = within(firstBodyRow).getByRole('textbox');
    expect(input).toBeInTheDocument();

    await userEvent.clear(input);
    await userEvent.type(input, 'Test');

    // edit mode renders two icon-only buttons in the row: [cancel, submit]
    const submitBtn = within(firstBodyRow).getAllByRole('button')[1];
    expect(submitBtn).toBeInTheDocument();
    await userEvent.click(submitBtn)

    expect(APIActions.put).toHaveBeenCalled();
    expect(APIActions.put).toHaveBeenCalledWith(
        expect.objectContaining({
          params: expect.objectContaining({ value: 'Test' }),
        })
    );
  })


  it('select value test', async () => {
    // display_fqdn_for_hosts is the second body row
    const displayRow = screen.getAllByRole('row')[2];
    const editButton = within(displayRow).getByRole('button');

    expect(editButton).toBeInTheDocument();
    await userEvent.click(editButton);

    const input = screen.getByRole('combobox');
    expect(input).toBeInTheDocument();

    await userEvent.selectOptions(input, 'No')

    const submitBtn = document.querySelector(
        'button[data-ouia-component-id="submit-edit-btn"]'
    );
    expect(submitBtn).toBeInTheDocument();
    await userEvent.click(submitBtn)

    expect(APIActions.put).toHaveBeenCalled();
    expect(APIActions.put).toHaveBeenCalledWith(
        expect.objectContaining({
          params: expect.objectContaining({ value: 'false' }),
        })
    );
  })


  it('array edit one value', async () => {
    await extracted('Test');
    expect(APIActions.put).toHaveBeenCalled();
    expect(APIActions.put).toHaveBeenCalledWith(
        expect.objectContaining({
          params: expect.objectContaining({ value: ['Test'] }),
        })
    );
  })

  it('array edit two values', async () => {
    await extracted('Test, Test2');
    expect(APIActions.put).toHaveBeenCalled();
    expect(APIActions.put).toHaveBeenCalledWith(
        expect.objectContaining({
          params: expect.objectContaining({ value: ['Test', 'Test2'] }),
        })
    );
  })

  it('array edit empty value', async () => {
    await extracted();
    expect(APIActions.put).toHaveBeenCalled();
    expect(APIActions.put).toHaveBeenCalledWith(
        expect.objectContaining({
          params: expect.objectContaining({ value: [] }),
        })
    );
  })

  it('renders each setting name, value and description', () => {
    // name column (SettingNameCell shows the fullName)
    expect(screen.getByText('Administrator email address')).toBeInTheDocument();
    // value column
    expect(screen.getByText('root@example.com')).toBeInTheDocument();
    // description column
    expect(
        screen.getByText('The default administrator email address')
    ).toBeInTheDocument();
  })

  it('cancel button exits edit mode without calling the API', async () => {
    // administrator is the first body row; open its edit via the row's button
    const administratorRow = screen.getAllByRole('row')[1];
    await userEvent.click(within(administratorRow).getByRole('button'));

    expect(screen.getByRole('textbox')).toBeInTheDocument();

    const callsBefore = APIActions.put.mock.calls.length;

    // the cancel/submit buttons are icon-only with no accessible name;
    // in edit mode the row renders them positionally as [cancel, submit]
    const cancelBtn = within(administratorRow).getAllByRole('button')[0];
    await userEvent.click(cancelBtn);

    // edit input is gone and the value is shown again
    expect(screen.queryByRole('textbox')).not.toBeInTheDocument();
    expect(screen.getByText('root@example.com')).toBeInTheDocument();
    // no update was submitted
    expect(APIActions.put.mock.calls.length).toBe(callsBefore);
  })

  it('pressing Escape exits edit mode without calling the API', async () => {
    const administratorRow = screen.getAllByRole('row')[1];
    await userEvent.click(within(administratorRow).getByRole('button'));

    const input = screen.getByRole('textbox');
    expect(input).toBeInTheDocument();

    const callsBefore = APIActions.put.mock.calls.length;

    await userEvent.type(input, '{Escape}');

    expect(screen.queryByRole('textbox')).not.toBeInTheDocument();
    expect(APIActions.put.mock.calls.length).toBe(callsBefore);
  })

  it('select (timezone) edit submits the chosen value', async () => {
    // default_timezone is the third body row
    const timezoneRow = screen.getAllByRole('row')[3];
    await userEvent.click(within(timezoneRow).getByRole('button'));

    const select = screen.getByRole('combobox');
    expect(select).toBeInTheDocument();

    await userEvent.selectOptions(select, 'Alaska');

    // the submit button is icon-only with no accessible name; in edit mode the
    // row renders the buttons positionally as [cancel, submit]
    const submitBtn = within(timezoneRow).getAllByRole('button')[1];
    await userEvent.click(submitBtn);

    expect(APIActions.put).toHaveBeenLastCalledWith(
        expect.objectContaining({
          params: expect.objectContaining({ value: 'Alaska' }),
        })
    );
  })

});
